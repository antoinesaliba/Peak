//
//  TableViewWorkoutCell.swift
//  Peak
//
//  Created by Antoine Saliba on 6/24/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit
import FoldingCell
import Charts

class TableViewWorkoutCell: FoldingCell, UIScrollViewDelegate{

    @IBOutlet weak var workoutName: UILabel!
    @IBOutlet weak var newDataButton: UIButton!
    @IBOutlet weak var lastData: UILabel!
    @IBOutlet weak var workoutChart: LineChartView!
    @IBOutlet weak var pagesController: UIScrollView!
    @IBOutlet weak var pagesIndicator: UIPageControl!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        pagesController.delegate = self
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        let durations = [0.33, 0.26, 0.26] // timing animation for each view
        return durations[itemIndex]
    }
    
    
    func createPages() {
        let chart:Chart = Bundle.main.loadNibNamed("Chart", owner: self, options: nil)?.first as! Chart
        let table:Table = Bundle.main.loadNibNamed("Table", owner: self, options: nil)?.first as! Table
        
        chart.isUserInteractionEnabled = false
        table.isUserInteractionEnabled = false
        //pagesController.isUserInteractionEnabled = false
        
        pagesController.frame = CGRect(x: 0, y: 0, width: pagesController.frame.width, height: pagesController.frame.width)
        pagesController.contentSize = CGSize(width: pagesController.frame.width * CGFloat(2), height: 194)
        chart.frame = CGRect(x: pagesController.frame.width * CGFloat(0), y: 0, width: pagesController.frame.width, height: pagesController.frame.width)
        table.frame = CGRect(x: pagesController.frame.width * CGFloat(1), y: 0, width: pagesController.frame.width, height: pagesController.frame.width)
        pagesController.addSubview(chart)
        pagesController.addSubview(table)
        pagesController.showsHorizontalScrollIndicator = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(pagesController.contentOffset.x/pagesController.frame.width)
        pagesIndicator.currentPage = Int(pageIndex)
    }
}
