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
    var body: some View {
        let graph = GraphView()
        let map = MapView()
        
        func fileUrlCallback(_ url: URL) {
            do {
                let csv = try CSV(url: url)
                let data = csv.asDataSet()!
                
                graph.loadData(data)
                map.loadData(data)
            } catch {
                print("Couldn't open or parse CSV")
                return
            }
        }

        return VStack {
            TabbedView {
                graph.tabItemLabel(Text("Graph")).tag(0);
                map.tabItemLabel(Text("Map")).tag(1);
            };
           
            PresentationLink("Load Data", destination: PickerView(callback: fileUrlCallback));
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


