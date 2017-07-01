//
//  TestViewController.swift
//  Peak
//
//  Created by Antoine Saliba on 6/24/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit

class TestViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, NewWorkoutProtocol {
    
    var workouts = ["Curls","Dips","Pull-Ups","Sit-Ups","Rows","Bench Press","Flyes","Squats"]
    
    @IBOutlet var workoutsTable: UITableView!
    @IBOutlet var newWorkoutView: UIView!
    @IBOutlet weak var newWorkoutName: UITextField!
    
    @IBAction func editWorkouts(_ sender: Any) {
        workoutsTable.isEditing = !workoutsTable.isEditing
    }
    
    @IBAction func addWorkout(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewWorkoutPopup") as! NewWorkoutPopup
        // 2. Set self as a value to delegate
        secondViewController.newWorkoutProtocol = self
        
        // 3. Push SecondViewController
        self.present(secondViewController, animated: true, completion: nil)
    }

    public func submitWorkout(newWorkoutName: String) {
        workouts.append(newWorkoutName)
        print(workouts.count)
        //self.workoutsTable.reloadData()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return (workouts.count)
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewWorkoutCell
        cell.workoutName.text = workouts[indexPath.row]
        cell.workoutContainer.layer.cornerRadius = 30.0
        
        return (cell)
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool
    {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = workouts[sourceIndexPath.row]
        workouts.remove(at: sourceIndexPath.row)
        workouts.insert(item, at: destinationIndexPath.row)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            workouts.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func createNewWorkout(name: String){
        workouts.append(name)
        workoutsTable.reloadData()
    }
    

}
