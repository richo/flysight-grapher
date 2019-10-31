//
//  SplitGraphMapView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/20/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import SwiftUI
import Charts

struct SplitGraphMapView : View {
    var graph: GraphView
    var map: MapView
    
    var body: some View {
        VStack {
            map;
            graph;
        }
    }
    
    func delegate() -> SplitViewDelegate {
        SplitViewDelegate(
            graph: self.graph,
            map: self.map
        )
    }
}

class SplitViewDelegate: ChartViewDelegate {
    var graph: GraphView
    var map: MapView
    
    init(graph: GraphView, map: MapView) {
        self.graph = graph
        self.map = map
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        if let index = self.graph.pointMap![entry.x] {
            self.map.highlightValue(index: index)
        } else {
            print("\(entry.x) was not found in the pointMap")
        }
    }
    
    deinit {
        print("Going away now :(")
    }
}
