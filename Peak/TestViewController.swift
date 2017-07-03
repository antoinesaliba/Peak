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
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    //move and delete specific workouts in main workouts table
    @IBAction func editWorkouts(_ sender: Any) {
        workoutsTable.isEditing = !workoutsTable.isEditing
        editButton.title = (workoutsTable.isEditing) ? "Done" : "Edit"
    }
    
    //opens the new workout popup
    @IBAction func addWorkout(_ sender: Any) {
        let popup = self.storyboard?.instantiateViewController(withIdentifier: "NewWorkoutPopup") as! NewWorkoutPopup
        popup.newWorkoutProtocol = self

        self.present(popup, animated: true, completion: nil)
    }
    
    //adds user inputed workout in popup to the workouts array and updates the main workouts table
    //if the workout name entered is already in the table it will not add it again
    func createNewWorkout(name: String){
        if !workouts.contains(name) {
            workouts.append(name)
            workoutsTable.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        workoutsTable.delegate = self
        workoutsTable.dataSource = self
        self.workoutsTable.contentInset = UIEdgeInsetsMake(15,0,0,0); //adds space between navigation bar and main workouts table
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Atami", size: 25)!] //set font and size of navigation bar title

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (workouts.count)
    }
    
    //code to set custom properties for all table cells
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewWorkoutCell
        cell.workoutName.text = workouts[indexPath.row]
        cell.workoutContainer.layer.cornerRadius = 30.0
        
        return (cell)
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
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
    
    //two functions below set up links for each workout cell to open workout detail page for specific workout
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "WorkoutInfoSegue", sender: workouts[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let infoview = segue.destination as! WorkoutInfoViewController
        infoview.workoutName = sender as! String
    }

}
