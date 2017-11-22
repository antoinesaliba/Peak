//
//  NewWorkoutPopup.swift
//  Peak
//
//  Created by Antoine Saliba on 6/29/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit

class NewWorkoutPopup: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var newWorkoutName: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.masksToBounds = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        newWorkoutName.becomeFirstResponder()
    }
}
