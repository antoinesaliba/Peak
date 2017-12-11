//
//  DetailsViewController
//  Peak
//
//  Created by Antoine Saliba on 12/9/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit

class DetailsViewController: UITableViewController {

    @IBOutlet var allDataTable: UITableView!
    var allData: [WorkoutData] = []
    var separateDatePoints: [String] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        allDataTable.delegate = self
        allDataTable.dataSource = self
        self.allDataTable.contentInset = UIEdgeInsetsMake(15,0,0,0); //adds space between navigation bar and main workouts table
        
        findSeparteDataPoints()
        
    }
    
    func findSeparteDataPoints(){
        var currentDate = -1
        for dataPoint in allData.reversed(){
            let formattedDate = dataPoint.printDate(includeYear: true)
            if (dataPoint.workoutDate != currentDate){
                let newPoint = String(formattedDate)+": "+String(dataPoint.workoutStat)
                separateDatePoints.append(newPoint)
                currentDate = dataPoint.workoutDate
            }else{
                let date = String(separateDatePoints.last!.prefix(12))
                let index = separateDatePoints.last!.index(separateDatePoints.last!.startIndex, offsetBy: 12)
                let previousData = separateDatePoints.last![index...]
                let moreData = date+String(dataPoint.workoutStat)+", "+previousData
                separateDatePoints.removeLast()
                separateDatePoints.append(moreData)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (separateDatePoints.count)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTableCell = tableView.dequeueReusableCell(withIdentifier: "datapoint", for: indexPath) as! DataPointTableCell
        currentTableCell.dataForDate.text = separateDatePoints[indexPath.row]
        return (currentTableCell)
    }
}
