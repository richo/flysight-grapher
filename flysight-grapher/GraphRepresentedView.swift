//
//  GraphRepresentedView.swift
//  flysight-grapher
//
//  Created by richö butts on 7/8/19.
//  Copyright © 2019 richö butts. All rights reserved.
//

import Foundation
import SwiftUI
import Charts
import class SwiftCSV.CSV

let MetersPerSecondToMilesPerHour = 2.23694
let MetersToFeet = 3.28084

struct GraphRepresentedView: UIViewRepresentable {
    var view: LineChartView = LineChartView()
    
    func makeUIView(context: UIViewRepresentableContext<GraphRepresentedView>) -> GraphRepresentedView.UIViewType {
        // Configure the lineChart
        view.noDataText = "No data loaded."
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GraphRepresentedView>) {
        // Update the view.
    }
    
    func presentData(data: LineChartData) {
        view.data = data
    }
}

struct GraphView: View {
    var graph: GraphRepresentedView = GraphRepresentedView()
    
    var body: some View {
        self.graph
    }
    
    func loadData(_ data: DataSet) {
        // TODO(richo) Deal with this error better
        self.graph.presentData(data: transformData(data))
    }
}

fileprivate func transformData(_ data: DataSet) -> LineChartData {
    var hMSL: Array<ChartDataEntry> = []
    var velX: Array<ChartDataEntry> = []
    var velY: Array<ChartDataEntry> = []
    
    for point in data.data {
        hMSL.append(ChartDataEntry(x: point.time, y: point.altitude * MetersToFeet))
        velY.append(ChartDataEntry(x: point.time, y: point.vY() * MetersPerSecondToMilesPerHour))
        
        
        velX.append(ChartDataEntry(x: point.time, y: point.vX() *
            MetersPerSecondToMilesPerHour))
    }
    
    let alt = LineChartDataSet(entries: hMSL, label: "altitude")
    alt.axisDependency = .left
    alt.setColor(.black)
    alt.drawCirclesEnabled = false
    alt.lineWidth = 2
    
    let vSpeed = LineChartDataSet(entries: velY, label: "v speed")
    vSpeed.axisDependency = .right
    vSpeed.setColor(.green)
    vSpeed.drawCirclesEnabled = false
    vSpeed.lineWidth = 2
    
    let hSpeed = LineChartDataSet(entries: velX, label: "h speed")
    hSpeed.axisDependency = .right
    hSpeed.setColor(.red)
    hSpeed.drawCirclesEnabled = false
    hSpeed.lineWidth = 2
    
    
    let data = LineChartData(dataSets: [alt, vSpeed, hSpeed])
    data.setValueTextColor(.black)
    data.setValueFont(.systemFont(ofSize: 9))
    
    return data
}
