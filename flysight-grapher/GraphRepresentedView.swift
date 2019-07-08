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

struct GraphRepresentedView: UIViewRepresentable {
    func makeUIView(context: UIViewRepresentableContext<GraphRepresentedView>) -> GraphRepresentedView.UIViewType {
        // Configure the lineChart
        let view = LineChartView()
        view.noDataText = "No data provided"
        view.data = getData(25, range: 5)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<GraphRepresentedView>) {
        // Update the view.
    }
}

struct GraphView: View {
    var body: some View {
        GraphRepresentedView()
    }
}

func getData(_ count: Int, range: UInt32) -> LineChartData {
    let yVals1 = (0..<count).map { (i) -> ChartDataEntry in
        let mult = range / 2
        let val = Double(arc4random_uniform(mult) + 50)
        return ChartDataEntry(x: Double(i), y: val)
    }
    let yVals2 = (0..<count).map { (i) -> ChartDataEntry in
        let val = Double(arc4random_uniform(range) + 450)
        return ChartDataEntry(x: Double(i), y: val)
    }
    let yVals3 = (0..<count).map { (i) -> ChartDataEntry in
        let val = Double(arc4random_uniform(range) + 500)
        return ChartDataEntry(x: Double(i), y: val)
    }
    
    let set1 = LineChartDataSet(entries: yVals1, label: "DataSet 1")
    set1.axisDependency = .left
    set1.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
    set1.setCircleColor(.white)
    set1.lineWidth = 2
    set1.circleRadius = 3
    set1.fillAlpha = 65/255
    set1.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
    set1.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
    set1.drawCircleHoleEnabled = false
    
    let set2 = LineChartDataSet(entries: yVals2, label: "DataSet 2")
    set2.axisDependency = .right
    set2.setColor(.red)
    set2.setCircleColor(.white)
    set2.lineWidth = 2
    set2.circleRadius = 3
    set2.fillAlpha = 65/255
    set2.fillColor = .red
    set2.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
    set2.drawCircleHoleEnabled = false
    
    let set3 = LineChartDataSet(entries: yVals3, label: "DataSet 3")
    set3.axisDependency = .right
    set3.setColor(.yellow)
    set3.setCircleColor(.white)
    set3.lineWidth = 2
    set3.circleRadius = 3
    set3.fillAlpha = 65/255
    set3.fillColor = UIColor.yellow.withAlphaComponent(200/255)
    set3.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
    set3.drawCircleHoleEnabled = false
    let data = LineChartData(dataSets: [set1, set2, set3])
    data.setValueTextColor(.white)
    data.setValueFont(.systemFont(ofSize: 9))
    
    return data
}
