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
    
    func loadDataFromCSV(_ csv: CSV) {
        // TODO(richo) Deal with this error better
        self.graph.presentData(data: parseGraphDataFromCSV(csv)!)
    }
    
}

func parseGraphDataFromCSV(_ csv: CSV) -> LineChartData? {
    let dateFormatter = DateFormatter()
    
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
    
    do {
        var hMSL: Array<ChartDataEntry> = []
        var velD: Array<ChartDataEntry> = []
        

        try csv.validRows { dict in
            let ts = dateFormatter.date(from: dict["time"]!)!
            let secs = ts.timeIntervalSince1970
        
            hMSL.append(ChartDataEntry(x: secs, y: Double(dict["hMSL"]!)!))
            velD.append(ChartDataEntry(x: secs, y: Double(dict["velD"]!)!))
        }
        
        let alt = LineChartDataSet(entries: hMSL, label: "altitude")
        alt.axisDependency = .left
        alt.setColor(UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1))
        alt.drawCirclesEnabled = false
        alt.lineWidth = 5
        alt.fillAlpha = 65/255
        alt.fillColor = UIColor(red: 51/255, green: 181/255, blue: 229/255, alpha: 1)
        alt.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        alt.drawCircleHoleEnabled = false
        
        let vSpeed = LineChartDataSet(entries: velD, label: "v speed")
        vSpeed.axisDependency = .right
        vSpeed.setColor(.red)
        vSpeed.drawCirclesEnabled = false
        vSpeed.lineWidth = 2
        vSpeed.fillAlpha = 65/255
        vSpeed.fillColor = .red
        vSpeed.highlightColor = UIColor(red: 244/255, green: 117/255, blue: 117/255, alpha: 1)
        // vSpeed.drawCircleHoleEnabled = false
        
        let data = LineChartData(dataSets: [alt, vSpeed])
        data.setValueTextColor(.white)
        data.setValueFont(.systemFont(ofSize: 9))
        
        return data
    } catch {
        // log("Done a whoopsie")
        return nil
    }
}


