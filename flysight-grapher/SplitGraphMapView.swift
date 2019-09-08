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
}

class SplitViewDelegate: ChartViewDelegate {
    var map: MapView?
    var graph: GraphView?
    
    func setGraph(_ graph: GraphView) {
        self.graph = graph
    }
    
    func setMap(_ map: MapView) {
        self.map = map
    }
    
    func chartValueSelected(_ chartView: ChartViewBase, entry: ChartDataEntry, highlight: Highlight) {
        let index = self.graph!.graph.pointMap[entry.x]!
        self.map!.highlightValue(index: index)
    }
    
    deinit {
        print("Going away now :(")
    }
}
