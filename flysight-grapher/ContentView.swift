//
//  ContentView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI
import MapKit

struct ContentView : View {
    var body: some View {
        let graph = GraphView()
        let map = GraphView()
        let loadButton = Button(action: {
            graph.loadDataFromCSV(getFileURL())
        }) {
            Text("Load data")
        }

        return VStack {
            TabbedView {
                graph.tabItemLabel(Text("Graph"));
                map.tabItemLabel(Text("Map"));
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
