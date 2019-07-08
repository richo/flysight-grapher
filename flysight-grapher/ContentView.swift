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
        let loadButton = Button(action: {
            graph.loadDataFromCSV(getFileURL())
        }) {
            Text("Load data")
        }

        return VStack {
            graph;
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
