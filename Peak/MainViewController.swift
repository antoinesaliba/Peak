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
    var databaseContext:NSManagedObjectContext! //initialize database context so it can be reused throughout file
    
    @IBOutlet var workoutsTable: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func addWorkoutData(_ sender: UIButton) {
        let popup = self.storyboard?.instantiateViewController(withIdentifier: "NewDataPopup") as! NewDataPopup
        popup.newDataProtocol = self
        popup.workoutName = workouts[sender.tag].workoutname!
        
        self.present(popup, animated: true, completion: nil)
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
    
    //adds user inputed workout in popup to the workouts array and updates the main workouts table
    //if the workout name entered is already in the table it will not add it again
    func createNewWorkout(name: String){
        if noDuplicateWorkout(newWorkout: name) {
            let newWorkout = Workout(context: databaseContext)
            newWorkout.workoutname = name
            saveData(workout: newWorkout, plainData: [10,12,15])
            workouts.append(newWorkout)
            workoutsTable.reloadData()
        }
    }
    
    func findWorkoutElement(name: String) -> Workout {
        let i = workouts.index(where: { $0.workoutname == name })
        return workouts[i!]
    }
    
    func addData(name: String, newData: String) {
        print("HELLO")
        let workout = findWorkoutElement(name: name)
        var workoutData = getData(binaryData: workout.data!)
        let input = Int(newData)
        workoutData.append(input!)
        saveData(workout: workout, plainData: workoutData)
    }
    
    func getData(binaryData: NSData) -> [Int] {
        return NSKeyedUnarchiver.unarchiveObject(with: binaryData as Data) as! [Int]
    }
    
    func saveData(workout: Workout, plainData: [Int]) {
        let binaryData = NSKeyedArchiver.archivedData(withRootObject: plainData)
        workout.setValue(binaryData, forKey: "data")
        do {
            try databaseContext.save()
        }catch{
            print ("Error saving new workout data to database.")
        }
    }
    
    func noDuplicateWorkout(newWorkout: String) -> Bool{
        for workout in workouts{
            if workout.value(forKey: "workoutname") as! String == newWorkout {
                return false
            }
        }
        return true
    }
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.tableFooterView = UIView()
        
        workoutsTable.delegate = self
        workoutsTable.dataSource = self
        
        self.workoutsTable.contentInset = UIEdgeInsetsMake(15,0,0,0); //adds space between navigation bar and main workouts table
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Atami", size: 25)!] //set font and size of navigation bar title
        
        databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        request.returnsObjectsAsFaults = false
        
        let date = NSDate()
        let formatter = DateFormatter()
        //MM-dd-yyyy-hh-mm-ss also available
        formatter.dateFormat = "yyyyMMddhhmmss"
        let result = formatter.string(from: date as Date)
        print(result)
        
        
        do{
            let results = try databaseContext.fetch(request)
            workouts = results as! [Workout]
        }catch{
            print ("Error loading workouts from database.")
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (workouts.count)
    }
    
    //code to set custom properties for all table cells
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewWorkoutCell
        cell.workoutName.text = workouts[indexPath.row].value(forKey: "workoutname") as? String
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
            databaseContext.delete(workouts[indexPath.row])
            do{
                try databaseContext.save()
            }catch{
                print("Failed to save deleted workout to database.")
            }

            workouts.remove(at: indexPath.row)
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
        let selectedWorkoutData = getData(binaryData: selectedWorkout.data!)
        infoview.workoutName = selectedWorkout.workoutname!
        if selectedWorkoutData.count > 0 {
            let stringArray = selectedWorkoutData.map
            {
                String($0)
            }
            infoview.workoutData = stringArray.joined(separator: " ")
        }
    }
    
}
