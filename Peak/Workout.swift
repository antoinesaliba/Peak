//
//  Workout.swift
//  Peak
//
//  Created by Antoine Saliba on 7/24/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import Foundation

class Workout: NSObject, NSCoding {
    
    struct Keys {
        static let workoutName = "workoutName"
        static let workoutData = "workoutData"
    }
    
    var workoutName: String = ""
    var workoutData: [WorkoutData] = []
    
    init(name: String, data: [WorkoutData]) {
        self.workoutName = name
        self.workoutData = data
    }
    
    required init(coder decoder: NSCoder) {
        if let nameObj = decoder.decodeObject(forKey: Keys.workoutName) as? String {
            self.workoutName = nameObj
        }
        if let dataObj = decoder.decodeObject(forKey: Keys.workoutData) as? [WorkoutData] {
            workoutData = dataObj
        }
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(workoutName, forKey: Keys.workoutName)
        coder.encode(workoutData, forKey: Keys.workoutData)
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
