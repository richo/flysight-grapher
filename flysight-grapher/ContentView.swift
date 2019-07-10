//
//  ContentView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI

struct ContentView : View {
    var body: some View {
        let graph = GraphView()
        let map = MapView()
        
        func fileUrlCallback(_ url: URL) {
            let csv = getCSV(url)!
            
            
            graph.loadDataFromCSV(csv)
            map.loadDataFromCSV(csv)
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


