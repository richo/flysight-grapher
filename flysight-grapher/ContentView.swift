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
            graph.loadDataFromCSV()
        }) {
            Text("Load data")
        }

        return VStack {
            graph;
            loadButton;
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
