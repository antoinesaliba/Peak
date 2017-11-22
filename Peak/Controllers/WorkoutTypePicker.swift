//
//  workoutTypePicker.swift
//  Peak
//
//  Created by Antoine Saliba on 11/20/17.
//  Copyright © 2017 Antoine Saliba. All rights reserved.
//

import UIKit

@IBDesignable
class WorkoutTypePicker: UIControl {
    
    var workoutTypeChoices = [UIButton]()
    var selectedWorkoutType: UIView!
    var selectedWorkoutTypeIndex = 0
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var commaSeparatedWorkoutChoices: String = "" {
        didSet {
            updateWorkoutTypeSelector()
        }
    }
    
    @IBInspectable
    var textColor: UIColor = .lightGray {
        didSet {
            updateWorkoutTypeSelector()
        }
    }
    
    @IBInspectable
    var selectedWorkoutTypetColor: UIColor = .darkGray {
        didSet {
            updateWorkoutTypeSelector()
        }
    }
    
    @IBInspectable
    var selectedWorkoutTypetTextColor: UIColor = .white {
        didSet {
            updateWorkoutTypeSelector()
        }
    }
    
    func updateWorkoutTypeSelector(){
        workoutTypeChoices.removeAll()
        subviews.forEach { (view) in
            view.removeFromSuperview()
        }
        
        let selectorChoices = commaSeparatedWorkoutChoices.components(separatedBy: ",")
        for choice in selectorChoices {
            let button = UIButton(type: .system)
            button.setTitle(choice, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.titleLabel?.textAlignment = NSTextAlignment.center
            button.addTarget(self, action: #selector(buttonClicked(chosenType:)), for: .touchUpInside)
            workoutTypeChoices.append(button)
        }
        
        workoutTypeChoices[0].setTitleColor(selectedWorkoutTypetTextColor, for: .normal)
        
        let selectedWorkoutTypeWidth = frame.width / CGFloat(selectorChoices.count)
        selectedWorkoutType = UIView(frame: CGRect(x: 0, y: 0, width: selectedWorkoutTypeWidth, height: frame.height))
        selectedWorkoutType.layer.cornerRadius = frame.height/2
        selectedWorkoutType.backgroundColor = selectedWorkoutTypetColor
        addSubview(selectedWorkoutType)
        
        let stackView = UIStackView(arrangedSubviews: workoutTypeChoices)
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        stackView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        stackView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.height/2
        updateWorkoutTypeSelector()
    }
    
    @objc func buttonClicked(chosenType: UIButton){
        for (buttonIndex, button) in workoutTypeChoices.enumerated() {
            button.setTitleColor(textColor, for: .normal)
            
            if button == chosenType {
                let selectedWorkoutTypeStartPosition = frame.width/CGFloat(workoutTypeChoices.count) * CGFloat(buttonIndex)
                selectedWorkoutTypeIndex = buttonIndex
                UIView.animate(withDuration: 0.2, animations: {
                    self.selectedWorkoutType.frame.origin.x = selectedWorkoutTypeStartPosition
                })
                button.setTitleColor(selectedWorkoutTypetTextColor, for: .normal)
            }
        }
        sendActions(for: .valueChanged)
    }
}
