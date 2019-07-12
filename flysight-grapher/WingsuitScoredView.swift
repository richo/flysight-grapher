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

struct WingsuitScoredView : View {
    
    @ObjectBinding var scores: WingsuitScoreData = WingsuitScoreData()
    
    var body: some View {
        List {
            if !scores.valid {
                Section(header: Text("Warning")) {
                    Text("Loaded run does not contain a valid performance run")
                }
            } else {
                Section(header: Text("Distance")) {
                    ScoreView(score: scores.distance, unit: "m")
                }
                Section(header: Text("Time")) {
                    ScoreView(score: scores.time, unit: "s")
                }
                Section(header: Text("Speed")) {
                    ScoreView(score: scores.speed, unit: "m/s")

                }
            }
        }.listStyle(.grouped)
    }
    
    func loadData(_ data: DataSet) {
        var state: WindowState = .BeforeEntry
        var entry: GateCrossing? = nil
        var exit: GateCrossing? = nil
        
        outer: for point in data.data {
            switch state {
            case .BeforeEntry:
                if point.altitude < 3000 {
                    print("Found the entry gate")
                    entry = GateCrossing(position: point.position, time: point.time)
                    state = .InWindow
                }
            case .InWindow:
                if point.altitude < 2000 {
                    print("Found the exit gate")
                    exit = GateCrossing(position: point.position, time: point.time)
                    state = .AfterExit
                    break outer
                }
            case .AfterExit:
                break outer
            }
        }
        
        // TODO(richo) Expose something in the UI
        guard let entryGate = entry, let exitGate = exit else {
            scores.invalidRun()
            return
        }

        scores.validRun(entry: entryGate, exit: exitGate)
    }
    
    enum WindowState {
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
        return Text("\(score)\(unit)")
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
    let position: CLLocationCoordinate2D
    let time: Double
}

#if DEBUG
struct WingsuitScoredView_Previews : PreviewProvider {
    static var previews: some View {
        WingsuitScoredView()
    }
}
#endif

// TODO(unify this with the swoop stuff
final class WingsuitScoreData: BindableObject  {
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
