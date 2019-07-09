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
        let loadButton = Button(action: {
            let url = getFileURL();
            let csv = getCSV(url)!
            
            graph.loadDataFromCSV(csv)
            map.loadDataFromCSV(csv)
        }) {
            Text("Load data")
        }

        return VStack {
            TabbedView {
                graph.tabItemLabel(Text("Graph")).tag(0);
                map.tabItemLabel(Text("Map")).tag(1);
            };
            loadButton;
        }
    }
}

func getFileURL() -> URL {
    return URL(fileURLWithPath: Bundle.main.path(forResource: "dummy-data", ofType: "csv")!)
}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
