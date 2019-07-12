//
//  WingsuitScoredView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/11/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI
import MapKit

struct WingsuitScoredView : View {
    var speed = ScoreView()
    var time = ScoreView()
    var distance = ScoreView()
    
    var showInvalidRun = false
    
    var body: some View {
        List {
            if showInvalidRun {
                Section(header: Text("Warning")) {
                    Text("Loaded run does not contain a valid performance run")
                }
            }
            Section(header: Text("Speed")) {
                speed
            }
            Section(header: Text("Time")) {
                time
            }
            Section(header: Text("Distance")) {
                distance
            }
        }.listStyle(.grouped)
    }
    
    mutating func loadData(_ data: DataSet) {
        var state: WindowState = .BeforeEntry
        var entry: GateCrossing? = nil
        var exit: GateCrossing? = nil
        
        for point in data.data {
            switch state {
            case .BeforeEntry:
                if point.altitude == 3000 {
                    entry = GateCrossing(position: point.position, time: point.time)
                    state = .InWindow
                }
            case .InWindow:
                if point.altitude == 2000 {
                    exit = GateCrossing(position: point.position, time: point.time)
                    state = .AfterExit
                    break
                }
            case .AfterExit:
                print("unreachable!")
                break
            }
        }
        
        // TODO(richo) Expose something in the UI
        guard let entryGate = entry, let exitGate = exit else {
            showInvalidRun = true
            return
        }
        
        speed.loadSpeed(entryGate, exitGate)
        distance.loadDistance(entryGate, exitGate)
        time.loadTime(entryGate, exitGate)
    }
    
    enum WindowState {
        case BeforeEntry
        case InWindow
        case AfterExit
    }
}

struct ScoreView: View {
    var score: Double?
    var body: some View {
        guard let score = score else {
            return Text("No data")
        }
        return Text("Score: \(score)")
    }
    
    mutating func loadSpeed(_ entry: GateCrossing, _ exit: GateCrossing) {
        let distance = self.distance(entry, exit)
        let time = self.time(entry, exit)
        
        score = distance / time
    }
    
    mutating func loadDistance(_ entry: GateCrossing, _ exit: GateCrossing) {
        score = distance(entry, exit)
    }
    
    mutating func loadTime(_ entry: GateCrossing, _ exit: GateCrossing) {
        score = time(entry, exit)
    }
    
    fileprivate func distance(_ entry: GateCrossing, _ exit: GateCrossing) -> Double {
        let entryPoint = MKMapPoint(entry.position)
        let exitPoint = MKMapPoint(exit.position)
        let distance = entryPoint.distance(to: exitPoint)
        
        return distance
    }
    
    fileprivate func time(_ entry: GateCrossing, _ exit: GateCrossing) -> Double {
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
