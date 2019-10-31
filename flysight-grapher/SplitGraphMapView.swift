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
    
    var timeToIndexMap: [Double: Int]?;

    
    init(graph: GraphView, map: MapView) {
        self.graph = graph
        self.map = map
    }

    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = self.timeToIndexMap![entry.x]!
        self.map.highlightPoint(index: index)
    }
    
    deinit {
        print("Going away now :(")
    }
}
