//
//  SettingsView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/11/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation
import SwiftUI

struct SettingsView : View {
    @State var showPerfWindow = true

    var body: some View {

        return VStack {
            Text("Settings go in here (none of them work yet)")
            Toggle(isOn: $showPerfWindow) {
                Text("Show wingsuit performance window")
            }.padding()
        }
    }
}
