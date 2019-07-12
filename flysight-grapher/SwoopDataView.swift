//
//  SwoopDataView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/11/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI

struct SwoopDataView : View {
    fileprivate var maxVert = DataView(label: "Max vertical speed")
    fileprivate var rolloutHorizontal = DataView(label: "Rollout horizontal")

    var body: some View {
        List {
            Section(header: Text("Swoop")) {
                maxVert
            }
        }.listStyle(.grouped)
    }
    
    let TWO_THOUSAND_FEET = 2000 / MetersToFeet
    mutating func loadData(_ data: DataSet) {
        let swoop = data.data.filter { $0.altitude < TWO_THOUSAND_FEET }
        let maxVerticalSpeed = swoop.max { a, b in  a.vY() < b.vY() }
        maxVert.score = maxVerticalSpeed!.vY()
        
        let rolloutSpeed = swoop
            .filter { $0.altitude < 5 / MetersToFeet}
            .max { a, b in  a.vX() < b.vX() }
        rolloutHorizontal.score = rolloutSpeed!.vX()
    }
}

fileprivate struct DataView: View {
    var score: Double?
    var label: String
    
    var body: some View {
        guard let score = score else {
            return Text("No data")
        }
        return Text("\(label): \(score)")
    }
}

#if DEBUG
struct SwoopDataView_Previews : PreviewProvider {
    static var previews: some View {
        SwoopDataView()
    }
}
#endif
