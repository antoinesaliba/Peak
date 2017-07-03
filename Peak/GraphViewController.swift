//
//  GraphViewController.swift
//  Peak
//
//  Created by Antoine Saliba on 6/10/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit

class GraphViewController: UIViewController {
    
    //MARK: Properties
    let colorDictionary = [
        "Red":UIColor(
            red: 1.0,
            green: 0.0,
            blue: 0.0,
            alpha: 1.0),
        "Green":UIColor(
            red: 0.0,
            green: 1.0,
            blue: 0.0, alpha: 1.0),
        "Blue":UIColor(
            red: 0.0,
            green: 0.0,
            blue: 1.0,
            alpha: 1.0),
        ]

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
