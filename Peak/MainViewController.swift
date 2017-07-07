//
//  MainViewController.swift
//  Peak
//
//  Created by Antoine Saliba on 6/24/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UITableViewController, NewWorkoutProtocol {
    
    var workouts:[Workout] = []
    var databaseContext:NSManagedObjectContext! //initialize database context so it can be reused throughout file
    var testAr:[Int] = []
    
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
        if noDuplicateWorkout(newWorkout: name) {
            let newWorkout = Workout(context: databaseContext)
            newWorkout.workoutname = name
            let testArray = [12,43,45,21,56]
            let data = NSKeyedArchiver.archivedData(withRootObject: testArray)
            newWorkout.setValue(data, forKey: "data")
        
            do{
                try databaseContext.save()
                workouts.append(newWorkout)
                workoutsTable.reloadData()
            }catch{
                print ("Error saving new workout to database.")
            }
        }
        let pa = NSKeyedArchiver.archivedData(withRootObject: [10])
        findWorkoutElement(name: "Test").setValue(pa, forKey: "data")
        do {
            try databaseContext.save()
        }catch{
            print ("Error!!")
        }
        let datar = findWorkoutElement(name: "Test").value(forKey: "data") as! NSData
        let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: datar as Data)
        let arrayObject = unarchiveObject as AnyObject! as! [Int]
        testAr = arrayObject
        for element in testAr{
            print (element)
        }

    }
    
    func findWorkoutElement(name: String) -> Workout {
        let i = workouts.index(where: { $0.workoutname == name })
        return workouts[i!]
    }
    
    func noDuplicateWorkout(newWorkout: String) -> Bool{
        for workout in workouts{
            if workout.value(forKey: "workoutname") as! String == newWorkout {
                return false
            }
        }
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        workoutsTable.delegate = self
        workoutsTable.dataSource = self
        self.workoutsTable.contentInset = UIEdgeInsetsMake(15,0,0,0); //adds space between navigation bar and main workouts table
        self.navigationController?.navigationBar.titleTextAttributes = [ NSFontAttributeName: UIFont(name: "Atami", size: 25)!] //set font and size of navigation bar title
        
        databaseContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Workout")
        request.returnsObjectsAsFaults = false
        
        do{
            let results = try databaseContext.fetch(request)
            workouts = results as! [Workout]
            if workouts[0].data != nil{
                let datar = workouts[0].value(forKey: "data") as! NSData
                let unarchiveObject = NSKeyedUnarchiver.unarchiveObject(with: datar as Data)
                let arrayObject = unarchiveObject as AnyObject! as! [Int]
                testAr = arrayObject
                for element in testAr{
                    print (element)
                }
            }
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
        performSegue(withIdentifier: "WorkoutInfoSegue", sender: workouts[indexPath.row].workoutname)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let infoview = segue.destination as! WorkoutInfoViewController
        infoview.workoutName = sender as! String
    }

}
