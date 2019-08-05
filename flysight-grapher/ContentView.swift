//
//  ContentView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI
import class SwiftCSV.CSV

struct ContentView : View {
    var isiPhone = UIDevice.current.userInterfaceIdiom == .phone
    @State var showFilePicker = false

    
    var body: some View {
        let graph = GraphView()
        let map = MapView()
        let split = SplitGraphMapView(
            graph: graph,
            map: map
        )

        var swoop = SwoopDataView()
        var wingsuit = WingsuitScoredView()
        
        func fileUrlCallback(_ url: URL) {
            do {
                let csv = try CSV(url: url)
                let data = csv.asDataSet()!
                
                DispatchQueue.main.async {
                    print("Loading data into graph")
                    graph.loadData(data)
                    print("Loading data into map")
                    map.loadData(data)
                    
                    print("Loading data into wingsuit view")
                    wingsuit.loadData(data)
                    print("Loading data into swoop view")
                    swoop.loadData(data)
                }
            } catch {
                print("Couldn't open or parse CSV")
                return
            }
        }
        
        let settings = SettingsView(loadFile: fileUrlCallback)

        return VStack {
            TabView {
                graph.tabItem({ Text("Graph") }).tag(0);
                map.tabItem({ Text("Map") }).tag(1);
//                if !isiPhone {
                    split.tabItem({ Text("Split") }).tag(2);
//                }
                swoop.tabItem({ Text("Swoop Data") }).tag(3);
                wingsuit.tabItem({ Text("Wingsuit Data") }).tag(4);
                settings.tabItem({ Text("Settings") }).tag(5);
            };
            Button("Load Data") {
                self.showFilePicker = true
            }
        }
        .sheet(isPresented: $showFilePicker, content: { PickerView(callback: fileUrlCallback) })
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
