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

struct PerformanceView : View, DataPresentable {
    
    @ObservedObject var wingsuitScores: WingsuitScoreData = WingsuitScoreData()
    @ObservedObject var swoopScores: SwoopScoreData = SwoopScoreData()
    @ObservedObject var flares: WingsuitFlareData = WingsuitFlareData()
    
    var body: some View {
        VStack {
            Section(header: Text("Wingsuit performance")) {
                if !wingsuitScores.valid {
                    Text("Loaded run does not contain a valid wingsuit performance run")
                } else {
                    List {
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
                    }.listStyle(.grouped)
                }
            }

            Section(header: Text("Flares")) {
                List(flares.getFlares()) { flare in
                    FlareView(flare:  flare)
                }.listStyle(.grouped)
            }
            
            Section(header: Text("Swoops")) {
                List {
                    HStack {
                        Text("Max Vertical")
                        ScoreView(score: swoopScores.maxVerticalSpeed, unit: "mph")
                    }
                    HStack {
                        Text("Rollout Horizontal Speed")
                        ScoreView(score: swoopScores.rolloutHorizontalSpeed, unit: "mph")
                    }
                }
            }.listStyle(.grouped)
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
                    print("Found the entry gate")
                    entry = GateCrossing(position: point.position, time: point.time, altitude: point.altitude)
                    state = .InWindow
                }
            case .InWindow:
                if point.altitude < 2000 {
                    print("Found the exit gate")
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
        swoopScores.maxVerticalSpeed = maxVerticalSpeed!.vY() * MetersPerSecondToMilesPerHour
        
        let rolloutSpeed = swoop
            .filter { $0.altitude < 3 / MetersToFeet}
            .max { a, b in  a.vX() < b.vX() }
        swoopScores.rolloutHorizontalSpeed = rolloutSpeed!.vX() * MetersPerSecondToMilesPerHour
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

struct ScoreView: View {
    var score: Double?
    var unit: String
    
    var body: some View {
        guard let score = score else {
            return Text("No data")
        }
        return Text(String(format: "%.1f%@", score, unit))
    }
}

struct FlareView: View {
    var flare: Flare
    
    var body: some View {
        Section(header: Text("flare")) {
            Text(String(format: "%.1fm", flare.height()))
            Text(String(format: "Time to peak %.1fs ", flare.timeToPeak()))
            Text(String(format: "Distance to peak %.1fm", flare.distanceToPeak()))
            Button("Highlight") { // TODO(richo) highlight this in the map
                
            }
        }
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

struct Flare: Identifiable {
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

struct WingsuitScorer {
    func speed(_ entry: GateCrossing, _ exit: GateCrossing) -> Double {
        let distance = self.distance(entry, exit)
        let time = self.time(entry, exit)
        
        return distance / time
    }

    func distance(_ entry: GateCrossing, _ exit: GateCrossing) -> Double {
        let entryPoint = MKMapPoint(entry.position)
        let exitPoint = MKMapPoint(exit.position)
        let distance = entryPoint.distance(to: exitPoint)
        
        return distance
    }
    
    func time(_ entry: GateCrossing, _ exit: GateCrossing) -> Double {
        let exitTime = exit.time
        let entryTime = entry.time
        
        return exitTime - entryTime
    }
}

struct GateCrossing {
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
    let didChange = PassthroughSubject<WingsuitFlareData, Never>()
    var measurer = WingsuitFlareMeasurer()
    
    var max: Double? = nil {
        didSet {
            didChange.send(self)
        }
    }
    
    var flares: Array<Flare>? = nil {
        didSet {
            didChange.send(self)
        }
    }
    
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
    let didChange = PassthroughSubject<WingsuitScoreData, Never>()
    var scorer = WingsuitScorer()

    
    var valid = false {
        didSet {
            didChange.send(self)
        }
    }
    var distance: Double? = nil {
        didSet {
            didChange.send(self)
        }
    }
    var time: Double? = nil {
        didSet {
            didChange.send(self)
        }
    }
    var speed: Double? = nil {
        didSet {
            didChange.send(self)
        }
    }
    
    func validRun(entry: GateCrossing, exit: GateCrossing) {
        self.distance = scorer.distance(entry, exit)
        self.time = scorer.time(entry, exit)
        self.speed = scorer.speed(entry, exit)
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
    let didChange = PassthroughSubject<SwoopScoreData, Never>()
    
    var valid = false {
        didSet {
            didChange.send(self)
        }
    }
    
    var maxVerticalSpeed: Double? = nil {
        didSet {
            didChange.send(self)
        }
    }
    var rolloutHorizontalSpeed: Double? = nil {
        didSet {
            didChange.send(self)
        }
    }
}
