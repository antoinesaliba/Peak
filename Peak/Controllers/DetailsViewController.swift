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
    var separateDatePoints = 0
    
    
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
        for dataPoint in allData{
            if (dataPoint.workoutDate != currentDate){
                separateDatePoints+=1;
                currentDate = dataPoint.workoutDate
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (separateDatePoints)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let currentTableCell = tableView.dequeueReusableCell(withIdentifier: "datapoint", for: indexPath) as! DataPointTableCell
        return (currentTableCell)
    }
}
