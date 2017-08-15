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
import FoldingCell
import PopupDialog
import Charts

class MainViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    fileprivate struct C {
        struct CellHeight {
            //both open and close need to be either the height of the containers or bigger
            static let close: CGFloat = 140  // space between closed rows in workout table
            static let open: CGFloat = 260  // space between open rows in workout table
        }
    }
    
    var workouts:[Workout] = []
    
    @IBOutlet var workoutsTable: UITableView!
    @IBOutlet weak var detailedView: UIView!
    
    var dragInitialIndexPath: IndexPath?
    var popoutCell: UIView?
    var cellHeights = [CGFloat]()
    
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
        cellHeights = (0..<workouts.count).map { _ in C.CellHeight.close }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = 0.2
        tableView.addGestureRecognizer(longPress)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //opens the new workout popup
    @IBAction func addWorkout(_ sender: Any) {
        let newWorkoutPopup = self.storyboard?.instantiateViewController(withIdentifier: "NewWorkoutPopup") as! NewWorkoutPopup
        
        // Create the dialog
        let popup = PopupDialog(viewController: newWorkoutPopup, buttonAlignment: .horizontal)
        
        // Create first button
        let buttonOne = CancelButton(title: "Cancel", height: 60) {}
        
        // Create second button
        let buttonTwo = DefaultButton(title: "Submit", height: 60) {
            self.createNewWorkout(name: newWorkoutPopup.newWorkoutName.text!)
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    //opens new data popup
    @IBAction func addWorkoutData(_ sender: UIButton) {
        let newDataPopup = self.storyboard?.instantiateViewController(withIdentifier: "NewDataPopup") as! NewDataPopup
        newDataPopup.workoutName = workouts[sender.tag].workoutName
        
        // Create the dialog
        let popup = PopupDialog(viewController: newDataPopup, buttonAlignment: .horizontal)
        
        // Create first button
        let buttonOne = CancelButton(title: "Cancel", height: 60) {}
        
        // Create second button
        let buttonTwo = DefaultButton(title: "Submit", height: 60) {
            self.addData(name: newDataPopup.workoutName, newData: newDataPopup.newWorkoutData.text!)
        }
        
        popup.addButtons([buttonOne, buttonTwo])
        
        // Present dialog
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
            cellHeights = (0..<workouts.count).map { _ in C.CellHeight.close }
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
        workoutsTable.reloadData()
    }
    
    func saveData(workout: Workout, plainData: [WorkoutData]) {
        workout.workoutData = plainData
        NSKeyedArchiver.archiveRootObject(workouts, toFile: filePath)
    }
    
    func createChart(selectedCell: TableViewWorkoutCell, dataPoints: [WorkoutData]) {
        var dates: [String] = []
        var stats: [Double] = []
        for i in 0..<dataPoints.count {
            dates.append(dataPoints[i].printDate())
            stats.append(Double(dataPoints[i].workoutStat))
        }
        selectedCell.workoutChart.setLineChartData(xValues: dates, yValues: stats, label: "Pounds")
        
        selectedCell.workoutChart.xAxis.labelPosition = .bottom
        selectedCell.workoutChart.xAxis.avoidFirstLastClippingEnabled = true
        selectedCell.workoutChart.chartDescription?.enabled = false
        selectedCell.workoutChart.rightAxis.enabled = false
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
        cell.newDataButton.tag = indexPath.row
        if workouts[indexPath.row].workoutData.count > 0 {
            cell.lastData.text = "Last workout: "+String(describing: workouts[indexPath.row].workoutData.last!.workoutStat)+"lb"
        } else {
            cell.lastData.text = ""
        }
        cell.foregroundView.layer.cornerRadius = 30.0
        cell.containerView.layer.cornerRadius = 30.0
        cell.workoutChart.isUserInteractionEnabled = false //enables cell closing when graph clicked
        
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard case let cell as TableViewWorkoutCell = tableView.cellForRow(at: indexPath as IndexPath) else {
            return
        }
        
        let data = findWorkoutElement(name: cell.workoutName.text!).workoutData
        
        var duration = 0.0
        if cellHeights[indexPath.row] == C.CellHeight.close { // open cell
            if data.count > 0 {
                createChart(selectedCell: cell, dataPoints: data)
            }
            cellHeights[indexPath.row] = C.CellHeight.open
            cell.selectedAnimation(true, animated: true, completion: nil)
            duration = 0.0
        } else {// close cell
            cellHeights[indexPath.row] = C.CellHeight.close
            cell.selectedAnimation(false, animated: true, completion: nil)
            duration = 0.25
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: { _ in
            tableView.beginUpdates()
            tableView.endUpdates()
        }, completion: nil)
        
        //enables automatic scrolling to center that workout in view when workout is expanded
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case let cell as TableViewWorkoutCell = cell {
            if cellHeights[indexPath.row] == C.CellHeight.close {
                cell.selectedAnimation(false, animated: false, completion:nil)
            } else {
                cell.selectedAnimation(true, animated: false, completion: nil)
            }
        }
    }
    
    //functionality to move cell by long pressing
    func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        let locationInView = sender.location(in: tableView) //where on the screen was long pressed
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        if sender.state == .began { //if long pressed
            if indexPath != nil {
                dragInitialIndexPath = indexPath
                let selectedCell = tableView.cellForRow(at: indexPath!) //get cell user long pressed
                popoutCell = snapshotOfCell(inputView: selectedCell!) //create popout cell
                var center = selectedCell?.center
                popoutCell?.center = center! //centers popout cell to where user long pressed
                popoutCell?.alpha = 0.0 //hidden at first
                tableView.addSubview(popoutCell!)
                
                //gives popout cell an animation
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    self.popoutCell?.center = center!
                    self.popoutCell?.transform = (self.popoutCell?.transform.scaledBy(x: 1.05, y: 1.05))!
                    self.popoutCell?.alpha = 0.99
                    selectedCell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        selectedCell?.isHidden = true //hides non-popout cell that is behind popout cell
                    }
                })
            }
        } else if sender.state == .changed && dragInitialIndexPath != nil { //if released long press
            var center = popoutCell?.center
            center?.y = locationInView.y
            popoutCell?.center = center!
            
            if indexPath != nil && indexPath != dragInitialIndexPath { //if longpress not in same position
                let dataToMove = workouts[dragInitialIndexPath!.row]
                workouts.remove(at: dragInitialIndexPath!.row)
                workouts.insert(dataToMove, at: indexPath!.row)
                NSKeyedArchiver.archiveRootObject(workouts, toFile: filePath)
                
                tableView.moveRow(at: dragInitialIndexPath!, to: indexPath!)
                dragInitialIndexPath = indexPath
            }
        } else if sender.state == .ended && dragInitialIndexPath != nil { //if done, make cell reappear
            let cell = tableView.cellForRow(at: dragInitialIndexPath!)
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.popoutCell?.center = (cell?.center)!
                self.popoutCell?.transform = CGAffineTransform.identity
                self.popoutCell?.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished { //get rid of popout cell
                    self.dragInitialIndexPath = nil
                    self.popoutCell?.removeFromSuperview()
                    self.popoutCell = nil
                    self.workoutsTable.reloadData()
                }
            })
        }
    }
    
    //creates pop-out effect when cell is long pressed
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}
