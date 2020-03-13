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

let MetersPerSecondToMilesPerHour = 2.23694
let MetersToFeet = 3.28084
let DEFAULT_RIGHT_AXIS_MINIMUM = -5.0

struct GraphRepresentedView: UIViewRepresentable {
    var view = FlysightGraph()
    
    func makeUIView(context: UIViewRepresentableContext<GraphRepresentedView>) -> GraphRepresentedView.UIViewType {
        // Make sure we nopped out drawCircles
        let oldRenderer = view.renderer
        
        view.renderer = NoFrillsLineChartRenderer(dataProvider: view, animator: oldRenderer!.animator, viewPortHandler: oldRenderer!.viewPortHandler)
        
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
//        self.view.autoScaleMinMaxEnabled = true

        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GraphRepresentedView>) {
    }
    
    func presentData(data: LineChartData) {
        view.data = data
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
        var dAngle: Array<ChartDataEntry> = []
        var exitLineData: Array<ChartDataEntry> = []
        

        var minVelX = 0.0
        var minVelY = 0.0
        
        var intermediateMap = [Double: Int]()
                
        for (i, point) in data.data.enumerated() {
            hMSL.append(ChartDataEntry(x: point.time, y: point.altitude * MetersToFeet))
            velY.append(ChartDataEntry(x: point.time, y: point.vY() * MetersPerSecondToMilesPerHour))
            velX.append(ChartDataEntry(x: point.time, y: point.vX() *
                MetersPerSecondToMilesPerHour))
            dAngle.append(ChartDataEntry(x: point.time, y: point.angle()))
            
//            if i + 5 < len {
//                let soon = data.data[i + 5]
//                let change = point.vY() - soon.vY()
//                dY.append(ChartDataEntry(x: point.time, y: change * -1000))
//            }
            
            if point.vY() < minVelY {
                minVelY = point.vY()
            }
            if point.vX() < minVelX {
                minVelX = point.vX()
            }
            
            intermediateMap[point.time] = i
        }
        
        if let exit = data.exitFrame {
            exitLineData.append(ChartDataEntry(
                x: data.data.first!.time,
                y: data.data[exit].altitude * MetersToFeet
            ))
            exitLineData.append(ChartDataEntry(
                x: data.data.last!.time,
                y: data.data[exit].altitude * MetersToFeet
            ))
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
        
        let angle = LineChartDataSet(entries: dAngle, label: "angle")
        angle.axisDependency = .right
        let angleColor = UIColor(named: "graphAngle")!
        angle.setColor(angleColor)
        angle.drawCirclesEnabled = false
        angle.lineWidth = 2
        
        let exitLine = LineChartDataSet(entries: exitLineData, label: "exit")
        angle.axisDependency = .left
        let exitLineColor = UIColor(named: "graphExitLine")!
        exitLine.setColor(exitLineColor)
        exitLine.drawCirclesEnabled = false
        exitLine.lineWidth = 1
        
        let data = LineChartData(dataSets: [alt, vSpeed, hSpeed, angle, exitLine])
        let valueTextColor = UIColor(named: "graphText")!
        data.setValueTextColor(valueTextColor)
        data.setValueFont(.systemFont(ofSize: 9))
        
        let min_axis_value = min(minVelY, minVelX)
        
        print("Setting axis min")
        self.graph.view.rightAxis.axisMinimum = min(DEFAULT_RIGHT_AXIS_MINIMUM, min_axis_value)
        print("Presenting data")
        self.graph.presentData(data: data)
        print("Loading pointMap, has \(intermediateMap.count) entries")
        
        (self.graph.view.delegate! as! SplitViewDelegate).timeToIndexMap = intermediateMap
    }
}

#if DEBUG
struct GraphRepresentedView_Previews : PreviewProvider {
    static var previews: some View {
        GraphRepresentedView()
    }
}
#endif

class NoFrillsLineChartRenderer: LineChartRenderer {
    override func drawExtras(context: CGContext) {
        print("Not drawing extras")
    }
}
