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
            print(value)
            return ""
        }
        
        init(labels: [String]) {
            super.init()
            self.labels = labels
        }
    }
    
    func setLineChartData(xValues: [String]) {
        
        let chartFormatter = LineChartFormatter(labels: xValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = chartFormatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
    }
}
