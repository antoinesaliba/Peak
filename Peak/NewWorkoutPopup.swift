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
    
    @IBAction func submitAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navigation = segue.destination as! UINavigationController
        let mainViewController = navigation.viewControllers.first as! TestViewController
        
        mainViewController.workouts.append(newWorkoutName.text!)
        print(mainViewController.workouts.count)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 30.0
        popupView.layer.masksToBounds = true
    }

}
