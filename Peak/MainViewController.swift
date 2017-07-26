//
//  MainViewController.swift
//  Peak
//
//  Created by Antoine Saliba on 6/24/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit
import CoreData
import DZNEmptyDataSet

class MainViewController: UITableViewController, NewWorkoutProtocol, NewDataProtocol, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    var workouts:[Workout] = []
    
    @IBOutlet var workoutsTable: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    let filePath = "/Users/antoinesaliba/Programs/Swift/Peak/Peak/Data"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        workoutsTable.delegate = self
        workoutsTable.dataSource = self
        
        self.workoutsTable.contentInset = UIEdgeInsetsMake(15,0,0,0); //adds space between navigation bar and main workouts table
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Atami", size: 25)!] //set font and size of navigation bar title
        
        if let loadedData = NSKeyedUnarchiver.unarchiveObject(withFile: filePath) as? [Workout] {
            workouts = loadedData
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
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
    
    //opens new data popup
    @IBAction func addWorkoutData(_ sender: UIButton) {
        let popup = self.storyboard?.instantiateViewController(withIdentifier: "NewDataPopup") as! NewDataPopup
        popup.newDataProtocol = self
        popup.workoutName = workouts[sender.tag].workoutName
        
        self.present(popup, animated: true, completion: nil)
    }
    
    //checks to make sure no workout with the same title exist
    func noDuplicateWorkout(newWorkout: String) -> Bool{
        for workout in workouts{
            if workout.value(forKey: "workoutName") as! String == newWorkout {
                return false
            }
        }
        return true
    }
    
    //retrieve workout element based on name
    func findWorkoutElement(name: String) -> Workout {
        let i = workouts.index(where: { $0.workoutName == name })
        return workouts[i!]
    }
    
    //adds user inputed workout in popup to the workouts array and updates the main workouts table
    //if the workout name entered is already in the table it will not add it again
    func createNewWorkout(name: String){
        if noDuplicateWorkout(newWorkout: name) {
            let newWorkout = Workout(name: name, data: [])
            workouts.append(newWorkout)
            NSKeyedArchiver.archiveRootObject(workouts, toFile: filePath)
            workoutsTable.reloadData()
        }
    }
    
    func addData(name: String, newData: String) {
        let workout = findWorkoutElement(name: name)
        var workoutData = workout.workoutData
        let currentTime = getTime()
        let input = Int(newData)
        let newWorkoutData = WorkoutData(date: currentTime, stat: input!)
        workoutData.append(newWorkoutData)
        saveData(workout: workout, plainData: workoutData)
    }
    
    func saveData(workout: Workout, plainData: [WorkoutData]) {
        workout.workoutData = plainData
        NSKeyedArchiver.archiveRootObject(workouts, toFile: filePath)
    }
    
    //returns time as an Integer in yyyyMMddhhmmss format so it can be compared as an Integer
    func getTime() -> Int {
        let date = NSDate()
        let formatter = DateFormatter()
        //MM-dd-yyyy-hh-mm-ss also available
        formatter.dateFormat = "yyyyMMddhhmmss"
        return Int(formatter.string(from: date as Date))!
    }
    
    /* Next two methods are to set the title and text of the tableView when there are no workouts */
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Workouts"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the + button to add workouts"
        let attrs = [NSFontAttributeName: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    /* all remaining functions all involve doing dynamic actions for all table rows (aka workouts) */
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (workouts.count)
    }
    
    //code to set custom properties for all table cells
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewWorkoutCell
        cell.workoutName.text = workouts[indexPath.row].value(forKey: "workoutName") as? String
        cell.workoutContainer.layer.cornerRadius = 30.0
        cell.newDataButton.tag = indexPath.row
        
        return (cell)
    }
    
    public override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = workouts[sourceIndexPath.row]
        workouts.remove(at: sourceIndexPath.row)
        workouts.insert(item, at: destinationIndexPath.row)
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            workouts.remove(at: indexPath.row)
            NSKeyedArchiver.archiveRootObject(workouts, toFile: filePath)
            tableView.reloadData()
        }
    }
    
    //two functions below set up links for each workout cell to open workout detail page for specific workout
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "WorkoutInfoSegue", sender: workouts[indexPath.row])
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let infoview = segue.destination as! WorkoutInfoViewController
        let selectedWorkout = sender as! Workout
        let selectedWorkoutData = selectedWorkout.workoutData
        infoview.workoutName = selectedWorkout.workoutName
        if selectedWorkoutData.count > 0 {
            let stringArray = selectedWorkoutData.map
            {
                String($0.workoutStat)
            }
            infoview.workoutData = stringArray.joined(separator: " ")
        }
    }
    
}
