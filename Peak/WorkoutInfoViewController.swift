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
    
    var workoutName = "Default"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        name.text = workoutName
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
