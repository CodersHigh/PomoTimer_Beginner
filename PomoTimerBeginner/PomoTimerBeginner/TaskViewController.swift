//
//  ViewController.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 4. 13..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cycleCountButton: CircleButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startPauseButton: RoundButton!
    
    @IBOutlet var pomodoroImages: [UIImageView]!
    
    
    var currentCycle : Cycle!
    var todays:[Cycle] = []
    var timer : NSTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        currentCycle = Cycle()
        todays += [currentCycle]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTask() {
        if let activeTimer = timer {
            if currentCycle.currentTask == nil {
                currentCycle = Cycle()
                todays += [currentCycle]
            }
            
            currentCycle.progress()
        }
        
        updateUI()
    }
    
    func updateUI() {
        for (index, task) in enumerate(currentCycle.tasks) {
            pomodoroImages[index].image = UIImage(named: task.status.imageName)
        }
        
        if let activeTimer = timer {
            startPauseButton.setTitle("Pause", forState: .Normal)
            if let workingTask :Int = currentCycle.indexOfCurrentTask {
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = 1.0
                animation.toValue = 0.5
                animation.repeatCount = 1
                animation.duration = 0.5
                animation.autoreverses = true
                animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                
                self.pomodoroImages[workingTask].layer.addAnimation(animation, forKey:"pulse")
            }
        } else {
            startPauseButton.setTitle("Resume", forState: .Normal)
        }
        timeLabel.text = currentCycle.currentTask?.timeString
        cycleCountButton.setTitle("\(todays.count-1)", forState: .Normal)
        
    }
    
    @IBAction func toggleStart(sender: AnyObject) {
        if let activeTimer = timer {
            activeTimer.invalidate()
            timer = nil
            updateTask()
            currentCycle.stop()
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateTask", userInfo: nil, repeats: true)
            updateTask()
            currentCycle.start()
        }
        updateUI()
    }

    @IBAction func reset(sender: AnyObject) {
        if let activeTimer = timer {
            activeTimer.invalidate()
            timer = nil
        }
        currentCycle.resetTask()
        updateUI()
        startPauseButton.setTitle("Start", forState: .Normal)
    }
    
    
}

