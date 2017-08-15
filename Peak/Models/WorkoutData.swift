//
//  WorkoutData.swift
//  Peak
//
//  Created by Antoine Saliba on 7/23/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import Foundation

class WorkoutData: NSObject, NSCoding {
    
    struct Keys {
        static let workoutDate = "workoutDate"
        static let workoutStat = "workoutStat"
    }
    
    var workoutDate: Int = -1
    var workoutStat: Int = -1
    
    init(date: Int, stat: Int) {
        self.workoutDate = date
        self.workoutStat = stat
    }
    
    required init(coder decoder: NSCoder) {
        if let dateObj = decoder.decodeObject(forKey: Keys.workoutDate) {
            self.workoutDate = NSKeyedUnarchiver.unarchiveObject(with: dateObj as! Data) as! Int
        }
        if let statObj = decoder.decodeObject(forKey: Keys.workoutStat) {
            self.workoutStat = NSKeyedUnarchiver.unarchiveObject(with: statObj as! Data) as! Int
        }
    }
    
    func encode(with coder: NSCoder) {
        let encDate = NSKeyedArchiver.archivedData(withRootObject: workoutDate)
        coder.encode(encDate, forKey: Keys.workoutDate)
        let encStat = NSKeyedArchiver.archivedData(withRootObject: workoutStat)
        coder.encode(encStat, forKey: Keys.workoutStat)
    }
    
    func printDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let date = String(describing: formatter.date(from: String(self.workoutDate))!)
        let index = date.index(date.startIndex, offsetBy: 5)
        return date.substring(to: index)
    }
}
