//
//  WingsuitScoredView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/11/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI
import MapKit
import Combine

final class PerformanceSettings: ObservableObject {
    let objectWillChange = PassthroughSubject<Void, Never>()

    @UserDefault(key: "showWingsuitScores", defaultValue: true)
    var showWingsuitScores: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault(key: "showSwoopScores", defaultValue: true)
    var showSwoopScores: Bool {
        willSet {
            objectWillChange.send()
        }
    }
    
    @UserDefault(key: "showSpeedScores", defaultValue: false)
    var showSpeedScores: Bool {
        willSet {
            objectWillChange.send()
        }
    }
}

struct PerformanceView : View, DataPresentable {
    
    @ObservedObject var wingsuitScores: WingsuitScoreData = WingsuitScoreData()
    @ObservedObject var swoopScores: SwoopScoreData = SwoopScoreData()
    @ObservedObject var flares: WingsuitFlareData = WingsuitFlareData()
    @ObservedObject var speed: SpeedScoreData = SpeedScoreData()
    
    @EnvironmentObject var views: ViewContainer
    
    @ObservedObject private var settings = PerformanceSettings()
    @State private var flareSelection: Set<Flare> = []

    
    var body: some View {
        return VStack {
            List {
                Section(header: Toggle(isOn: $settings.showWingsuitScores) {
                    Text("Wingsuit performance")
                }) {
                    if settings.showWingsuitScores {
                        
                        if !wingsuitScores.valid {
                            Text("Loaded run does not contain a valid wingsuit performance run")
                        } else {
                            HStack {
                                Text("Distance")
                                ScoreView(score: wingsuitScores.distance, unit: "m")
                            }
                            HStack {
                                Text("Time")
                                ScoreView(score: wingsuitScores.time, unit: "s")
                            }
                            HStack {
                                Text("Speed")
                                ScoreView(score: wingsuitScores.speed, unit: "m/s")
                            }
                        }
                    }
                }
                
                if settings.showWingsuitScores {
                    Section(header: Text("Flares")) {
                        ForEach(flares.getFlares()) { flare in
                            FlareView(flare: flare,
                                      isExpanded: self.flareSelection.contains(flare))
                                .onTapGesture { self.selectDeselectFlare(flare) }
                                .onLongPressGesture {
                                    // self.views.graph.highlightFrames(flare.entry.time, flare.exit.time)
                                }
                                .animation(.linear(duration: 0.3))
                        }
                    }
                }
                
                Section(header: Toggle(isOn: $settings.showSwoopScores) {
                    Text("Swoop performance")
                }) {
                    if settings.showSwoopScores {
                        
                        HStack {
                            Text("Max Vertical")
                            SpeedScoreView(score: swoopScores.maxVerticalSpeed, unit: .MilesPerHour)
                        }
                        HStack {
                            Text("Rollout Horizontal Speed")
                            SpeedScoreView(score: swoopScores.rolloutHorizontalSpeed, unit: .MilesPerHour)
                            
                        }
                    }
                }
                
                Section(header: Toggle(isOn: $settings.showSpeedScores) {
                    Text("Speed performance")
                }) {
                    if settings.showSpeedScores {
                        HStack {
                            Text("Average speed")
                            SpeedScoreView(score: speed.speed, unit: .KilometersPerHour)
                        }
                        HStack {
                            Text("Exit altitude")
                            ScoreView(score: speed.exit, unit: "m")
                        }
                    }
                }
            }.listStyle(GroupedListStyle())
        }
    }
    
    func selectDeselectFlare(_ flare: Flare) {
        if flareSelection.contains(flare) {
            flareSelection.remove(flare)
        } else {
            flareSelection.insert(flare)
        }
    }
    
    let TWO_THOUSAND_FEET = 2000 / MetersToFeet

    func loadData(_ data: DataSet) {
        var state: WindowState = .InThePlane
        var entry: GateCrossing? = nil
        var exit: GateCrossing? = nil
        
        outer: for point in data.data {
            switch state {
            case .InThePlane:
                if point.vY() > 9 {
                    state = .BeforeEntry
                }
            case .BeforeEntry:
                if point.altitude < 3000 {
                    entry = GateCrossing(position: point.position, time: point.time, altitude: point.altitude)
                    state = .InWindow
                }
            case .InWindow:
                if point.altitude < 2000 {
                    exit = GateCrossing(position: point.position, time: point.time, altitude: point.altitude)
                    state = .AfterExit
                    break outer
                }
            case .AfterExit:
                break outer
            }
        }
        
        // TODO(richo) Expose something in the UI
        guard let entryGate = entry, let exitGate = exit else {
            wingsuitScores.invalidRun()
            return
        }

        wingsuitScores.validRun(entry: entryGate, exit: exitGate)
        flares.measureRun(data: data)
        
        // MARK: Swoop scoring
        
        let swoop = data.data.filter { $0.altitude < TWO_THOUSAND_FEET }
        let maxVerticalSpeed = swoop.max { a, b in  a.vY() < b.vY() }
        swoopScores.maxVerticalSpeed = maxVerticalSpeed!.vY()
        
        let rolloutSpeed = swoop
            .filter { $0.altitude < 3 / MetersToFeet}
            .max { a, b in  a.vX() < b.vX() }
        swoopScores.rolloutHorizontalSpeed = rolloutSpeed!.vX()
        
        speed.scoreRun(data: data)
    }
    
    func clearData() {
        // TODO(richo)
    }
    
    enum WindowState {
        case InThePlane
        case BeforeEntry
        case InWindow
        case AfterExit
    }
}

enum SpeedUnit {
    case MilesPerHour
    case KilometersPerHour
    case MetersPerSecond
}

struct SpeedScoreView: View {
    /// score is always in m/s
    let score: Double?
    let unit: SpeedUnit
    
    var body: some View {
        let value: String
        if let score = score {
            switch unit {
            case .MilesPerHour:
                value = String(format: "%.1fmph", score * MetersPerSecondToMilesPerHour)
            case .KilometersPerHour:
                // TODO(richo) We want to figure out how to make the precision figure itself out
                value = String(format: "%.2fkph", score * MetersPerSecondToKilometersPerHour)
            case .MetersPerSecond:
                value = String(format: "%.2fm/s", score)
            }
        } else {
            value = "No data"
        }
        
        return Text(value)
    }
}

struct ScoreView: View {
    let score: Double?
    let unit: String
    
    var body: some View {
        let value: String
        if let score = score {
            value = String(format: "%.1f%@", score, unit)
        } else {
            value = "No data"
        }
        
        return Text(value)
    }
}

struct FlareView: View {
    var flare: Flare
    let isExpanded: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(String(format: "%.1fm", flare.height())).font(.headline)
                if isExpanded {
                    Text(String(format: "Altitude initiated: %.1f'", flare.entry.altitude * MetersToFeet))
                    Text(String(format: "Time to peak %.1fs ", flare.timeToPeak()))
                    Text(String(format: "Distance to peak %.1fm", flare.distanceToPeak()))
                }
            }
            Spacer()
        }
        .contentShape(Rectangle())
    }
}

struct WingsuitFlareMeasurer {
    func flares(_ data: DataSet) -> Array<Flare> {
        var flares: Array<Flare> = []
        var state: FlareState = .InThePlane
        
        var entry: GateCrossing?
        var peak: GateCrossing?
        var exit: GateCrossing?

        outer: for point in data.data {
            if point.altitude * MetersToFeet < 2000 {
                break outer
            }
            
            switch state {
                // Naively just wait till we see >20 mph
                // We now have the exit! So we can rework this later
            case .InThePlane:
                if point.vY() > 9 {
                    state = .BeforeEntry
                }
            case .BeforeEntry:
                if point.vY() < 0 {
                    print("Found the start of a flare at \(point.altitude) meters")
                    entry = GateCrossing(position: point.position, time: point.time, altitude: point.altitude)
                    state = .WayUp
                }
            case .WayUp:
                if point.vY() > 0 {
                    print("Found the peak")
                    peak = GateCrossing(position: point.position, time: point.time, altitude: point.altitude)
                    state = .WayDown
                }
            case .WayDown:
                if point.altitude < entry!.altitude {
                    print("Found the exit")
                    exit = GateCrossing(position: point.position, time: point.time, altitude: point.altitude)
                    state = .BeforeEntry
                    
                    if let entry = entry, let peak = peak, let exit = exit {
                        let flare = Flare(entry: entry, peak: peak, exit: exit)
                        print("Sticking the flare into the array")
                        flares.append(flare)
                        print("Number of flares: \(flares.count)")
                    }
                    state = .BeforeEntry
                }
            }
        }
        
        for flare in flares {
            print("Flares: \(flare.height())")

        }
        return flares
    }
    
    static func max(_ flares: Array<Flare>) -> Flare? {
        let biggestFlare = flares.max { a, b in a.height() < b.height() }
        
        if let flare = biggestFlare {
            return flare
        } else {
            return nil
        }
    }
    
    enum FlareState {
        case InThePlane
        case BeforeEntry
        case WayUp
        case WayDown
    }
}

struct Flare: Identifiable, Hashable, Equatable {
    static func == (lhs: Flare, rhs: Flare) -> Bool {
        lhs.entry.altitude == rhs.entry.altitude
    }
    
    var id: Double {
        get {
            self.entry.altitude
        }
    }
    
    let entry: GateCrossing
    let peak: GateCrossing
    let exit: GateCrossing // Do we actually need the exit?
    
    func height() -> Double {
        self.peak.altitude - self.entry.altitude
    }
    
    func timeToPeak() -> Double {
        self.peak.time - self.entry.time
    }
    
    func distanceToPeak() -> Double {
        let entryPoint = MKMapPoint(entry.position)
        let peakPoint = MKMapPoint(peak.position)
        let distance = entryPoint.distance(to: peakPoint)
        
        return distance
    }
}

struct SpeedScorer {
    static func speed(data: DataSet) -> Double? {
        // TODO(richo) Surface why there are not scores.
        guard let exit = exitAltitude(data: data) else {
            return nil
        }
        guard let exitFrame = data.exitFrame else {
            return nil
        }
//        5.3.3 Maximum Exit Altitude: The maximum exit altitude for a valid jump is 14,000 ft. (4,267 metres) as measured by the approved competition SMD. A competitor should not exit the aircraft at a higher altitude than the maximum exit altitude. If the SMD registers a higher exit altitude than the maximum exit altitude, the jump will be considered as not valid and a re-jump will be granted.
        if exit > 4267 {
            return nil
        }
        
//        5.3.4 Minimum Exit Altitude: The minimum exit altitude for a valid jump is 13,000 ft. (3,962 metres) a competitor should not exit the aircraft at a lower altitude than the minimum altitude. If the SMD registers a lower exit altitude than the minimum exit altitude the competitor may choose to accept the score for the jump. The competitor must make an immediate decision and inform the Chief judge of their decision; otherwise a re-jump will be granted automatically.
        if exit < 3962 {
            // We can still score this, but we won't for now until we've figured out how to surface issues
            return nil
        }
        
        //        2.2 BREAKOFF ALTITUDE
        //        Breakoff altitude is set at 5,600 ft. (1,707 metres). Below the breakoff altitude no speed measurements are taken into account.
        //        2.3 PERFORMANCE WINDOW
        //        The performance window is the scoring part of the speed jump, which starts at exit. The end of the performance window is either 7,400 ft. (2,256 metres) below exit or at Breakoff altitude whichever is reached first.

        var maxSpeed = 0.0
        let bottomOfWindow = max(exit - 2256, 1707)
        for i in exitFrame...data.data.count {
            // Grab enough data to satisfy the window
            let start = data.data[i]
            // 5hz *should* mean exactly 15 frames, right?
            let end = data.data[i + 15]
            

            if end.altitude < bottomOfWindow {
                break
            }
            
            // assert(end.time - start.time == 3, "Ooops, windowing incorrect")
            
            //        5.5.1 The score for a Speed Skydiving jump is the average vertical speed in kilometres per hour, to the nearest hundredth of a km/h, of the fastest 3 seconds, which the competitor achieves within the performance window.
            let distance = end.altitude - start.altitude
            let time = end.time - start.time
            let speed = abs(distance / time)
            
            if speed > maxSpeed {
                maxSpeed = speed
            }
        }
        return maxSpeed
    }
    
    static func exitAltitude(data: DataSet) -> Double? {
        guard let exit = data.exitFrame else {
            return nil
        }
        return data.data[exit].altitude
    }
}

struct WingsuitScorer {
    static func speed(_ entry: GateCrossing, _ exit: GateCrossing) -> Double {
        let distance = self.distance(entry, exit)
        let time = self.time(entry, exit)
        
        return distance / time
    }

    static func distance(_ entry: GateCrossing, _ exit: GateCrossing) -> Double {
        let entryPoint = MKMapPoint(entry.position)
        let exitPoint = MKMapPoint(exit.position)
        let distance = entryPoint.distance(to: exitPoint)
        
        return distance
    }
    
    static func time(_ entry: GateCrossing, _ exit: GateCrossing) -> Double {
        let exitTime = exit.time
        let entryTime = entry.time
        
        return exitTime - entryTime
    }
}

struct GateCrossing: Hashable {
    static func == (lhs: GateCrossing, rhs: GateCrossing) -> Bool {
        lhs.altitude == rhs.altitude
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.time)
    }
    
    // TODO(richo) intitializer from point
    let position: CLLocationCoordinate2D
    let time: Double
    let altitude: Double
}

#if DEBUG
struct PerformanceView_Previews : PreviewProvider {
    static var previews: some View {
        PerformanceView()
    }
}
#endif

final class WingsuitFlareData: ObservableObject {
    var measurer = WingsuitFlareMeasurer()
    
    @Published var max: Double? = nil
    
    @Published var flares: Array<Flare>? = nil
    
    func getFlares() -> Array<Flare> {
        flares ?? []
    }
    
    func measureRun(data: DataSet) {
        let flares = measurer.flares(data)
        
        self.flares = flares
        self.max = WingsuitFlareMeasurer.max(flares).map { x in x.height() }
    }
}

// TODO(unify this with the swoop stuff
final class WingsuitScoreData: ObservableObject  {
    @Published var valid = false
    @Published var distance: Double? = nil
    @Published var time: Double? = nil
    @Published var speed: Double? = nil
    
    func validRun(entry: GateCrossing, exit: GateCrossing) {
        self.distance = WingsuitScorer.distance(entry, exit)
        self.time = WingsuitScorer.time(entry, exit)
        self.speed = WingsuitScorer.speed(entry, exit)
        self.valid = true
    }
    
    func invalidRun() {
        self.valid = false
        self.time = nil
        self.speed = nil
        self.distance = nil
    }
}

final class SwoopScoreData: ObservableObject  {
    @Published var valid = false

    @Published var maxVerticalSpeed: Double? = nil
    @Published var rolloutHorizontalSpeed: Double? = nil
}

final class SpeedScoreData: ObservableObject {
    @Published var speed: Double? = nil
    @Published var exit: Double? = nil
    
    func scoreRun(data: DataSet) {
        speed = SpeedScorer.speed(data: data)
        exit = exitAltitude(data: data)
    }
    
    private func exitAltitude(data: DataSet) -> Double? {
//        return SpeedScorer.exitAltitude(data: data).map({(alt) in alt * MetersToFeet})
        return SpeedScorer.exitAltitude(data: data)
    }
}
