//
//  NewDataPopup.swift
//  Peak
//
//  Created by Antoine Saliba on 7/21/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit

protocol NewDataProtocol {
    func addData(name: String, newData: String)
}

class NewDataPopup: UIViewController {

    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var newWorkoutData: UITextField!
    
    
    var workoutName=""
    
    var newDataProtocol:NewDataProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        popupView.layer.cornerRadius = 30.0
        popupView.layer.masksToBounds = true
    }
    @IBAction func submitAction(_ sender: Any) {
        newDataProtocol?.addData(name: workoutName, newData: newWorkoutData.text!)
        dismiss(animated: true, completion: nil)
    }
    @IBAction func cancelAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
