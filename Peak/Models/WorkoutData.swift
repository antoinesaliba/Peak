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
        let dateAsString = String(workoutDate)
        let year = substring(start: 0, offset: 5, input: dateAsString)
        let month = substring(start: 4, offset: -3, input: dateAsString)
        let day = substring(start: 6, offset: -5, input: dateAsString)
        
        return month+"/"+day+"/"+year
        
    }
    
    func substring(start: Int, offset: Int, input: String) -> String {
        if start == 0{
            let index = input.index(input.startIndex, offsetBy: offset)
            return input.substring(to: index)
            
        }else{
            let start = input.index(input.startIndex, offsetBy: start)
            let end = input.index(input.endIndex, offsetBy: offset)
            let range = start..<end
        
            return input.substring(with: range)
        }
    }
}
