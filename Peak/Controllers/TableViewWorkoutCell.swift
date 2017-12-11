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
    @IBOutlet weak var openCellWorkoutName: UILabel!
    @IBOutlet weak var newDataButton: UIButton!
    @IBOutlet weak var lastData: UILabel!
    @IBOutlet weak var workoutChart: LineChartView!
    @IBOutlet weak var allDataButton: UIButton!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func animationDuration(_ itemIndex:NSInteger, type:AnimationType)-> TimeInterval {
        let durations = [0.04, 0.04, 0.04] // timing animation for each view
        return durations[itemIndex]
    }
}
