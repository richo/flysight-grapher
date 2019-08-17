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
    
    @State var graph = GraphView()
    @State var map = MapView()
    @State var swoop = SwoopDataView()
    @State var wingsuit = WingsuitScoredView()
    var split: SplitGraphMapView {
        get {
            SplitGraphMapView(
                graph: graph,
                map: map
            )
            
        }
    }
    
    var body: some View {
        func fileUrlCallback(_ url: URL) {
            do {
                let csv = try CSV(url: url)
                let data = csv.asDataSet()!
                
                DispatchQueue.main.async {
                    print("Loading data into graph")
                    self.graph.clearData()
                    self.graph.loadData(data)
                    
                    print("Loading data into map")
                    self.graph.clearData()
                    self.map.loadData(data)
                    
                    print("Loading data into wingsuit view")
                    self.wingsuit.clearData()
                    self.wingsuit.loadData(data)
                    
                    print("Loading data into swoop view")
                    self.swoop.clearData()
                    self.swoop.loadData(data)
                }
            } catch {
                print("Couldn't open or parse CSV")
                return
            }
        }
        
        let settings = AboutView(loadFile: fileUrlCallback)

        return VStack {
            TabView {
                graph.tabItem({ Text("Graph") }).tag(0);
                map.tabItem({ Text("Map") }).tag(1);
                if !isiPhone {
                    split.tabItem({ Text("Split") }).tag(2);
                }
                swoop.tabItem({ Text("Swoop Data") }).tag(3);
                wingsuit.tabItem({ Text("Wingsuit Data") }).tag(4);
                settings.tabItem({ Text("About") }).tag(5);
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
