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
let DEFAULT_RIGHT_AXIS_MINIMUM = -5.0

struct GraphRepresentedView: UIViewRepresentable {
    var view: LineChartView = LineChartView()
    var pointMap = [Double: Int]()
    
    func makeUIView(context: UIViewRepresentableContext<GraphRepresentedView>) -> GraphRepresentedView.UIViewType {
        // Configure the lineChart
        view.noDataText = "No data loaded."
        let textColor = UIColor(named: "graphText")!

        view.noDataTextColor = textColor
        view.xAxis.labelTextColor = textColor
        
        view.leftAxis.labelTextColor = UIColor(named: "graphLeftAxis")!
        view.leftAxis.axisMinimum = -100
        
        view.rightAxis.labelTextColor = UIColor(named: "graphRightAxis")!
        view.rightAxis.gridLineWidth = 1.5
        view.rightAxis.axisMinimum = DEFAULT_RIGHT_AXIS_MINIMUM
        
        view.legend.textColor = textColor
        

        self.view.highlightPerTapEnabled = false
        self.view.doubleTapToZoomEnabled = false

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GraphRepresentedView>) {
    }
    
    func presentData(data: LineChartData) {
        view.data = data
    }
    
    mutating func loadPointMap(map: [Double: Int]) {
        self.pointMap = map
    }
}

struct GraphView: View, DataPresentable {
    func setDelegate(_ delegate: SplitViewDelegate) {
        self.graph.view.delegate = delegate
    }
    
    func clearData() {
        self.graph.view.data = nil
    }
    
    var graph: GraphRepresentedView = GraphRepresentedView()
    
    var body: some View {
        self.graph
    }
    
    mutating func loadData(_ data: DataSet) {
        var hMSL: Array<ChartDataEntry> = []
        var velX: Array<ChartDataEntry> = []
        var velY: Array<ChartDataEntry> = []
        
        var minVelX = 0.0
        var minVelY = 0.0
        
        var pointMap = [Double: Int]()
        
        for (i, point) in data.data.enumerated() {
            hMSL.append(ChartDataEntry(x: point.time, y: point.altitude * MetersToFeet))
            velY.append(ChartDataEntry(x: point.time, y: point.vY() * MetersPerSecondToMilesPerHour))
            velX.append(ChartDataEntry(x: point.time, y: point.vX() *
                MetersPerSecondToMilesPerHour))
            
            if point.vY() < minVelY {
                minVelY = point.vY()
            }
            if point.vX() < minVelX {
                minVelX = point.vX()
            }
            
            pointMap[point.time] = i
        }
        
        let alt = LineChartDataSet(entries: hMSL, label: "altitude")
        alt.axisDependency = .left
        let altitudeColor = UIColor(named: "graphAltitude")!
        alt.setColor(altitudeColor)
        alt.drawCirclesEnabled = false
        alt.lineWidth = 2
        
        let vSpeed = LineChartDataSet(entries: velY, label: "v speed")
        vSpeed.axisDependency = .right
        let vSpeedColor = UIColor(named: "graphVerticalSpeed")!
        vSpeed.setColor(vSpeedColor)
        vSpeed.drawCirclesEnabled = false
        vSpeed.lineWidth = 2
        
        let hSpeed = LineChartDataSet(entries: velX, label: "h speed")
        hSpeed.axisDependency = .right
        let hSpeedColor = UIColor(named: "graphHorizontalSpeed")!
        hSpeed.setColor(hSpeedColor)
        hSpeed.drawCirclesEnabled = false
        hSpeed.lineWidth = 2
        
        
        let data = LineChartData(dataSets: [alt, vSpeed, hSpeed])
        let valueTextColor = UIColor(named: "graphText")!
        data.setValueTextColor(valueTextColor)
        data.setValueFont(.systemFont(ofSize: 9))
        
        let min_axis_value = min(minVelY, minVelX)
        
        print("Setting axis min")
        self.graph.view.rightAxis.axisMinimum = min(DEFAULT_RIGHT_AXIS_MINIMUM, min_axis_value)
        print("Presenting data")
        self.graph.presentData(data: data)
        self.graph.loadPointMap(map: pointMap)
    }
}

#if DEBUG
struct GraphRepresentedView_Previews : PreviewProvider {
    static var previews: some View {
        GraphRepresentedView()
    }
}
#endif
