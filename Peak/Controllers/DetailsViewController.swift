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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableFooterView = UIView()
        allDataTable.delegate = self
        allDataTable.dataSource = self
        self.allDataTable.contentInset = UIEdgeInsetsMake(15,0,0,0); //adds space between navigation bar and main workouts table
        
    }

}
