//
//  LineChartView.swift
//  Peak
//
//  Created by Antoine Saliba on 8/14/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import Foundation
import Charts

extension LineChartView {
    
    private class LineChartFormatter: NSObject, IAxisValueFormatter {
        
        var labels: [String] = []
        
        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return labels[Int(value)]
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    
    func setLineChartData(xValues: [String], yValues: [Double], label: String) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<yValues.count {
            let dataEntry = ChartDataEntry(x: Double(i), y: yValues[i])
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: label)
        chartDataSet.colors = [UIColor.blue]
        chartDataSet.circleRadius = 4.0
        
        let chartData = LineChartData(dataSet: chartDataSet)
        chartData.setDrawValues(true)
        
        
        let chartFormatter = LineChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        
        self.data = chartData
    }
}
