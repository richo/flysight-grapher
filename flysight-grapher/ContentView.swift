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
    @State var performance = PerformanceView()
    @State var about = AboutView()

    
    @State var splitDelegate = SplitViewDelegate()

    var split: SplitGraphMapView {
        get {
            SplitGraphMapView(
                graph: graph,
                map: map
            )
        }
    }
    
    func loadData(_ url: URL) -> DataSet? {
        let loader = DataLoader()
        return loader.loadFromURL(url)
    }

    func fileUrlCallback(_ url: URL) {
        let data = loadData(url)!
        
        DispatchQueue.main.async {
            print("Loading data into graph")
            self.graph.clearData()
            self.graph.loadData(data)
            
            print("Loading data into map")
            self.map.clearData()
            self.map.loadData(data)
            
            print("Loading data into performance view")
            self.performance.clearData()
            self.performance.loadData(data)
            
            print("Setting up the split view delegate")
            self.splitDelegate.setGraph(self.graph)
            self.splitDelegate.setMap(self.map)
        }
    }
    
    var body: some View {

        
        graph.setDelegate(self.splitDelegate)

        return VStack {
            TabView {
                graph.tabItem({ Text("Graph") }).tag(0);
                map.tabItem({ Text("Map") }).tag(1);
                if !isiPhone {
                    split.tabItem({ Text("Split") }).tag(2);
                }
                performance.tabItem({ Text("Performance") }).tag(3);
                about.tabItem({ Text("About") }).tag(4);
            };
            Button("Load Data") {
                self.showFilePicker = true
            }.padding()
        }
        .sheet(isPresented: $showFilePicker, content: { PickerView(callback: self.fileUrlCallback) })
    }
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
