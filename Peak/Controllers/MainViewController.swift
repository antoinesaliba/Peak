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
import Persei

class MainViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    
    fileprivate struct C {
        struct CellHeight {
            //both open and close need to be either the height of the containers or bigger
            static let close: CGFloat = 140  // space between closed rows in workout table
            static let open: CGFloat = 380  // space between open rows in workout table
        }
    }
    
    var workouts:[Workout] = []
    
    @IBOutlet var workoutsTable: UITableView!
    @IBOutlet weak var detailedView: UIView!
    @IBOutlet weak var viewAllDataButton: UIButton!
    
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
        self.navigationController?.navigationBar.titleTextAttributes = [ NSAttributedStringKey.font: UIFont(name: "Atami", size: 25)!] //set font and size of navigation bar title
        
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
        
        let popup = PopupDialog(viewController: newWorkoutPopup, buttonAlignment: .horizontal, transitionStyle: .bounceUp)
        
        let cancelButton = CancelButton(title: "Cancel", height: 60) {}
        let submitButton = DefaultButton(title: "Submit", height: 60) {
            self.createNewWorkout(name: newWorkoutPopup.newWorkoutName.text!)
        }
        
        popup.addButtons([cancelButton, submitButton])
        
        self.present(popup, animated: true, completion: nil)
    }
    
    //opens new data popup
    @IBAction func addWorkoutData(_ sender: UIButton) {
        let newDataPopup = self.storyboard?.instantiateViewController(withIdentifier: "NewDataPopup") as! NewDataPopup
        newDataPopup.workoutName = workouts[sender.tag].workoutName
        
        let popup = PopupDialog(viewController: newDataPopup, buttonAlignment: .horizontal)
        
        let cancelButton = CancelButton(title: "Cancel", height: 60) {}
        let submitButton = DefaultButton(title: "Submit", height: 60) {
            self.addData(name: newDataPopup.workoutName, newData: newDataPopup.newWorkoutData.text!)
        }
        cancelButton.buttonColor = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        cancelButton.titleColor = UIColor.white
        cancelButton.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        submitButton.buttonColor = UIColor(red:0.25, green:0.25, blue:0.29, alpha:1.00)
        submitButton.titleColor = UIColor.white
        submitButton.separatorColor = UIColor(red:0.20, green:0.20, blue:0.25, alpha:1.00)
        
        popup.addButtons([cancelButton, submitButton])
        
        // Present dialog
        self.present(popup, animated: true, completion: nil)
    }
    
    //checks to make sure no workout with the same title exist
    func noDuplicateWorkout(newWorkout: String) -> Bool{
        for workout in workouts{
            if workout.workoutName == newWorkout {
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
    
    //adds workout data to a specific workout
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
    
    //stores workout data into file
    func saveData(workout: Workout, plainData: [WorkoutData]) {
        workout.workoutData = plainData
        NSKeyedArchiver.archiveRootObject(workouts, toFile: filePath)
    }
    
    //creates workout chart based on workout data points
    func createChart(selectedCell: TableViewWorkoutCell, dataPoints: [WorkoutData]) {
        var displayDates: [String] = []
        var dataEntries: [ChartDataEntry] = []
        var position = 0
        
        for element in dataPoints {
            var dataEntry:ChartDataEntry? = nil
            let displayD = element.printDate()
            if !displayDates.isEmpty && displayD == displayDates.last {
                if (dataEntries.last?.y)! < Double(element.workoutStat) {
                    position -= 1
                    dataEntries.removeLast()
                    displayDates.removeLast()
                } else {
                    continue
                }
            }
            dataEntry = ChartDataEntry(x: Double(position), y: Double(element.workoutStat))
            displayDates.append(displayD)
            dataEntries.append(dataEntry!)
            position += 1
        }
        
        let chartDataSet = LineChartDataSet(values: dataEntries, label: "")
        let lineColor = UIColor(red:1.00, green:0.90, blue:0.83, alpha:1.0)
        let dotColor = UIColor(red:1.00, green:0.37, blue:0.33, alpha:1.0)
        chartDataSet.colors = [lineColor]
        chartDataSet.circleRadius = 4.0
        chartDataSet.lineWidth = 3.0
        chartDataSet.drawFilledEnabled = true
        chartDataSet.fillColor = lineColor
        chartDataSet.setCircleColor(dotColor)
        chartDataSet.circleHoleColor = dotColor
        
        
        let chartData = LineChartData(dataSet: chartDataSet)
        chartData.setDrawValues(true)
        
        selectedCell.workoutChart.xAxis.labelPosition = .bottom
        selectedCell.workoutChart.xAxis.avoidFirstLastClippingEnabled = true
        selectedCell.workoutChart.chartDescription?.enabled = false
        selectedCell.workoutChart.rightAxis.enabled = false
        selectedCell.workoutChart.xAxis.drawLabelsEnabled = false
        selectedCell.workoutChart.leftAxis.drawLabelsEnabled = false
        selectedCell.workoutChart.leftAxis.drawGridLinesEnabled = false
        selectedCell.workoutChart.xAxis.drawGridLinesEnabled = false
        selectedCell.workoutChart.backgroundColor = UIColor.white
        selectedCell.workoutChart.legend.enabled = false
        selectedCell.workoutChart.isUserInteractionEnabled = false

        selectedCell.workoutChart.data = chartData
        
    }
    
    //returns time as an Integer in yyyyMMddhhmmss format so it can be compared as an Integer
    func getTime() -> Int {
        let date = NSDate()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddhhmmss"
        return Int(formatter.string(from: date as Date))!
    }
    
    /* Next two methods are to set the title and text of the tableView when there are no workouts */
    
    func title(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "No Workouts"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView) -> NSAttributedString? {
        let str = "Tap the + button to add workouts"
        let attrs = [NSAttributedStringKey.font: UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    /* all remaining functions all involve doing dynamic actions for all table rows (aka workouts) */
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (workouts.count)
    }
    
    //code to set custom properties for all table cells
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewWorkoutCell
        cell.workoutName.text = workouts[indexPath.row].workoutName
        cell.openCellWorkoutName.text = cell.workoutName.text
        cell.newDataButton.tag = indexPath.row
        cell.allDataButton.tag = indexPath.row
        cell.allDataButton.addTarget(self, action: #selector(self.viewAllData(_:)), for: .touchUpInside)
        if workouts[indexPath.row].workoutData.count > 0 {
            cell.lastData.text = "Last workout: "+String(describing: workouts[indexPath.row].workoutData.last!.workoutStat)+"lb"
        } else {
            cell.lastData.text = ""
            //cell.workoutChart.clear()
        }
        cell.foregroundView.layer.cornerRadius = 10.0
        cell.containerView.layer.cornerRadius = 10.0
        if !(cell.workoutChart.gestureRecognizers?.last is UITapGestureRecognizer) {
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
            tap.delegate = cell
            cell.workoutChart.addGestureRecognizer(tap)
            //cell.createPages()
        }
        cell.workoutChart.tag = indexPath.row
        
        return (cell)
    }
    
    @objc func viewAllData(_ sender:UIButton) {
        let retrievedData = workouts[sender.tag].workoutData
        let detailedView = self.storyboard?.instantiateViewController(withIdentifier: "DetailsViewController") as! DetailsViewController
        detailedView.allData = retrievedData
        self.navigationController?.pushViewController(detailedView, animated: true)
    }
    
    @objc func handleTap(_ sender:UITapGestureRecognizer){
        let index = sender.view?.tag
        let indexPath = IndexPath(row: index!, section: 0)
        switchWorkoutState(indexPath: indexPath, newState: C.CellHeight.close, makeChart: false)
    }

    public override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = workouts[sourceIndexPath.row]
        workouts.remove(at: sourceIndexPath.row)
        workouts.insert(item, at: destinationIndexPath.row)
    }
    
    //disables swipe to delete when cell is opened
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if cellHeights[indexPath.row] == C.CellHeight.close {
            return UITableViewCellEditingStyle.delete
        }else{
            return UITableViewCellEditingStyle.none
            
        }
    }
    
    //actions taken when user swipes to delete workout
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete{
            workouts.remove(at: indexPath.row)
            //tableView.deleteRows(at: [indexPath], with: .automatic)
            NSKeyedArchiver.archiveRootObject(workouts, toFile: filePath)
            tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeights[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if cellHeights[indexPath.row] == C.CellHeight.close { // open cell
            switchWorkoutState(indexPath: indexPath, newState: C.CellHeight.open, makeChart: true)
        } else {// close cell
            switchWorkoutState(indexPath: indexPath, newState: C.CellHeight.close, makeChart: false)
        }
        
    }
    
    func switchWorkoutState(indexPath: IndexPath, newState: CGFloat, makeChart: Bool){
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! TableViewWorkoutCell
        cellHeights[indexPath.row] = newState
        
        var duration = 0.0
        if makeChart{
            let data = workouts[indexPath.row].workoutData
            if data.count > 0 {
                createChart(selectedCell: cell, dataPoints: data)
            }
            duration = 0.1
            cell.unfold(true, animated: true, completion: nil)
        }else{
            duration = 0.2
            cell.unfold(false, animated: true, completion: nil)
        }
        
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
        }, completion: nil)
        
        //enables automatic scrolling to center that workout in view when workout is expanded
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if case let cell as TableViewWorkoutCell = cell {
            if cellHeights[indexPath.row] == C.CellHeight.close {
                cell.unfold(false, animated: false, completion:nil)
            } else {
                cell.unfold(true, animated: false, completion:nil)
            }
        }
    }
    
    //functionality to move cell by long pressing
    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
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
                let propertiesToMove = cellHeights[dragInitialIndexPath!.row]
                workouts.remove(at: dragInitialIndexPath!.row)
                cellHeights.remove(at: dragInitialIndexPath!.row)
                workouts.insert(dataToMove, at: indexPath!.row)
                cellHeights.insert(propertiesToMove, at: indexPath!.row)
                NSKeyedArchiver.archiveRootObject(workouts, toFile: filePath)
                
                tableView.moveRow(at: dragInitialIndexPath!, to: indexPath!)
                dragInitialIndexPath = indexPath
            }
        } else if sender.state == .ended && dragInitialIndexPath != nil { //if done, make cell reappear
            let cell = tableView.cellForRow(at: dragInitialIndexPath!) as! TableViewWorkoutCell
            //cell.pagesController.tag = indexPath!.row
            cell.isHidden = false
            cell.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.popoutCell?.center = (cell.center)
                self.popoutCell?.transform = CGAffineTransform.identity
                self.popoutCell?.alpha = 0.0
                cell.alpha = 1.0
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
