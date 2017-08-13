//
//  NewDataPopup.swift
//  Peak
//
//  Created by Antoine Saliba on 7/21/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit

class NewDataPopup: UIViewController {

    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var newWorkoutData: UITextField!
    
    var workoutName=""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.masksToBounds = true
    }
}
