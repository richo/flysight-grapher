//
//  ContentView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    @State var showFilePicker = false

    @EnvironmentObject var views: ViewContainer
    
    @State var defaultTab = 1
    var isiPhone = UIDevice.current.userInterfaceIdiom == .phone

    var body: some View {
        return VStack {
            TabView (selection: $defaultTab) {
                self.views.graph.tabItem({ Text("Graph") }).tag(0);
                self.views.map.tabItem({ Text("Map") }).tag(1);
                if !isiPhone {
                    self.views.split.tabItem({ Text("Split") }).tag(2);
                }
                self.views.performance.tabItem({ Text("Performance") }).tag(3);
                self.views.about.tabItem({ Text("About") }).tag(4);
            };
            Button("Load Data") {
                self.showFilePicker = true
            }.padding();
        }
        .sheet(isPresented: $showFilePicker, content: { PickerView(callback: self.views.fileUrlCallback) })
    }
    
    init() {
        if !isiPhone {
            self.defaultTab = 2
        }
    }
    

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
