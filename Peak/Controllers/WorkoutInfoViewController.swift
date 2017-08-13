//
//  WorkoutInfoViewController.swift
//  Peak
//
//  Created by Antoine Saliba on 7/3/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit

class WorkoutInfoViewController: UIViewController {

    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var data: UILabel!
    
    var workoutName = "Default"
    var workoutData = "No Data"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = workoutName
        data.text = workoutData
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
