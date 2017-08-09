//
//  NewWorkoutPopup.swift
//  Peak
//
//  Created by Antoine Saliba on 6/29/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit
import PopupDialog

protocol NewWorkoutProtocol {
    func createNewWorkout(name: String)
}

class NewWorkoutPopup: UIViewController {
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var newWorkoutName: UITextField!
    
    public weak var popup: PopupDialog?
    
    var newWorkoutProtocol:NewWorkoutProtocol?
    
    @IBAction func submitAction(_ sender: Any) {
        newWorkoutProtocol?.createNewWorkout(name: newWorkoutName.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //popupView.layer.cornerRadius = 30.0
        //popupView.layer.masksToBounds = true
    }

}
