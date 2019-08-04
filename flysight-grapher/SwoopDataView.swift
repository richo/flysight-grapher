//
//  SwoopDataView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/11/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI
import Combine

struct SwoopDataView : View {
    @ObservedObject var scores: SwoopScoreData = SwoopScoreData()
    
    var body: some View {
        List {
            Section(header: Text("Max Vertical")) {
                ScoreView(score: scores.maxVerticalSpeed, unit: "mph")
            }
            Section(header: Text("Rollout Horizontal Speed")) {
                ScoreView(score: scores.rolloutHorizontalSpeed, unit: "mph")
            }
        }.listStyle(.grouped)
    }
    
    let TWO_THOUSAND_FEET = 2000 / MetersToFeet
    mutating func loadData(_ data: DataSet) {
        let swoop = data.data.filter { $0.altitude < TWO_THOUSAND_FEET }
        let maxVerticalSpeed = swoop.max { a, b in  a.vY() < b.vY() }
        scores.maxVerticalSpeed = maxVerticalSpeed!.vY() * MetersPerSecondToMilesPerHour
        
        let rolloutSpeed = swoop
            .filter { $0.altitude < 3 / MetersToFeet}
            .max { a, b in  a.vX() < b.vX() }
        scores.rolloutHorizontalSpeed = rolloutSpeed!.vX() * MetersPerSecondToMilesPerHour
    }
}

#if DEBUG
struct SwoopDataView_Previews : PreviewProvider {
    static var previews: some View {
        SwoopDataView()
    }
}
#endif

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
