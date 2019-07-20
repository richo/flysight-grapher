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
    @State var developerMode = false
    
    let loadFile: (URL) -> ()

    var body: some View {
        let dummyAngle = Button(action: {
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: "dummy-angle", ofType: "csv")!)
            
            self.loadFile(url)
        }) {
            Text("Dummy Angle Jump")
        }
        let dummyWingsuit = Button(action: {
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: "dummy-wingsuit", ofType: "csv")!)
            
            self.loadFile(url)
        }) {
            Text("Dummy Wingsuit Flight")
        }
        let dummySwoop = Button(action: {
            let url = URL(fileURLWithPath: Bundle.main.path(forResource: "dummy-swoop", ofType: "csv")!)
            
            self.loadFile(url)
            
        }) {
            Text("Dummy Swoop")
        }
        
        return List {
            Section(header: Text("Wingsuit")) {
                Toggle(isOn: $showPerfWindow) {
                    Text("Show performance window in Graph view")
                }.padding()            }
            Section(header: Text("Developer")) {
                Toggle(isOn: $developerMode) {
                    Text("Debug stuff for development")
                }.padding()
                if developerMode {
                    dummyAngle;
                    dummyWingsuit;
                    dummySwoop;
                }
            }
        }.listStyle(.grouped)
    }
}

#if DEBUG
struct SettingsView_Previews : PreviewProvider {
    static var previews: some View {
        func cb(_url: URL) {
            
        }
        return SettingsView(loadFile: cb)
    }
}
#endif
