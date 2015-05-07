//
//  ViewController.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 4. 13..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import UIKit
import AVFoundation

class TaskViewController: UIViewController {
    
    @IBOutlet weak var cycleCountButton: CircleButton!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var startPauseButton: RoundButton!
    
    @IBOutlet var pomodoroImages: [UIImageView]!
    
    
    var currentCycle:Cycle!
    var todays:[Cycle] = []
    var timer:NSTimer?
    var audioPlayer:PomoAudioPlayer = PomoAudioPlayer() //환경설정에서 오디오가 없으면 초기화 하지 않아도 되겠지
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if currentCycle == nil {
            currentCycle = Cycle()
            todays += [currentCycle]
        }
    }
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
            startPauseButton.setTitle(NSLocalizedString("task_pause", comment:""), forState: .Normal)
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
            if let currentTask = currentCycle.currentTask {
                if currentTask.status == .PAUSE {
                    startPauseButton.setTitle(NSLocalizedString("task_resume", comment:""), forState: .Normal)
                } else {
                    startPauseButton.setTitle(NSLocalizedString("task_start", comment:""), forState: .Normal)
                }
            }
        }
        if let currentTask = currentCycle.currentTask {
            timeLabel.text = currentTask.timeString
        }
        cycleCountButton.setTitle("\(todays.count-1)", forState: .Normal)
        //updateAudio()
    }
    
    func updateAudio () {
        if let currentTask = currentCycle.currentTask {
            switch currentTask.status{
                case .COUNTING:
                    audioPlayer.setTick(currentTask)
                    if currentTask.time == 60 { audioPlayer.playChime() }
                case .PAUSE:
                    audioPlayer.stopTick()
                case .DONE:
                    println("Done chatched")
                    audioPlayer.playAlarm()
                default: ()
            }
        }
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
        //startPauseButton.setTitle("Start", forState: .Normal)
    }
    
    
}


class PomoAudioPlayer {
    let taskTickPlayer:AVAudioPlayer
    let taskTickRushPlayer:AVAudioPlayer
    let breakTickPlayer:AVAudioPlayer
    let minuteBellPlayer:AVAudioPlayer
    let timeoutBellPlayer:AVAudioPlayer
    //var alarmPlayer:AVAudioPlayer
    
    var currentTickPlayer:AVAudioPlayer?
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    init() {
        let tastTickFile:NSURL = NSBundle.mainBundle().URLForResource("tick_medium", withExtension: "aiff")!
        taskTickPlayer = AVAudioPlayer(contentsOfURL:tastTickFile, error: nil)
        taskTickPlayer.volume = 1.0
        taskTickPlayer.numberOfLoops = -1
        taskTickPlayer.prepareToPlay()

        let tastTickRushFile:NSURL = NSBundle.mainBundle().URLForResource("tick_hurry", withExtension: "aiff")!
        taskTickRushPlayer = AVAudioPlayer(contentsOfURL:tastTickRushFile, error: nil)
        taskTickRushPlayer.volume = 1.0
        taskTickRushPlayer.numberOfLoops = -1
        
        let breakTickFile:NSURL = NSBundle.mainBundle().URLForResource("tick_break", withExtension: "caf")!
        breakTickPlayer = AVAudioPlayer(contentsOfURL:breakTickFile, error: nil)
        breakTickPlayer.volume = 1.0
        breakTickPlayer.numberOfLoops = -1
        breakTickPlayer.prepareToPlay()
        
        let minuteBellFile:NSURL = NSBundle.mainBundle().URLForResource("beep_short", withExtension: "aiff")!
        minuteBellPlayer = AVAudioPlayer(contentsOfURL:minuteBellFile, error: nil)
        minuteBellPlayer.volume = 1.0
        minuteBellPlayer.numberOfLoops = 1
        
        let timeoutBellFile:NSURL = NSBundle.mainBundle().URLForResource("bell_long", withExtension: "aiff")!
        timeoutBellPlayer = AVAudioPlayer(contentsOfURL:timeoutBellFile, error: nil)
        timeoutBellPlayer.volume = 0.6
        timeoutBellPlayer.numberOfLoops = 0
        
        
        updateDefaultAudio(NSNotification(name: NSUserDefaultsDidChangeNotification, object: nil))
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateDefaultAudio:", name:NSUserDefaultsDidChangeNotification, object:nil)
    }
    
    @objc func updateDefaultAudio(notification: NSNotification) {
        //노티피케이션을 통해 넘어오는 데이터가 없으므로 오디오와 관련된 모든 사용자 정보를 업데이트 해야 함.
        
        let tick = userDefaults.boolForKey(Constants.UserDefaultKeys.kTick)
        if tick {
            playTick()
        } else {
            stopTick()
        }
        
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback, error: nil)
        let tickInBackground = userDefaults.boolForKey(Constants.UserDefaultKeys.kTickBackground)
        if tickInBackground {
            AVAudioSession.sharedInstance().setActive(true, error: nil)
            UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
        } else {
            AVAudioSession.sharedInstance().setActive(false, error: nil)
            UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        }
        
        let volume = userDefaults.floatForKey(Constants.UserDefaultKeys.kTickVolume)
        taskTickPlayer.volume = volume
        taskTickRushPlayer.volume = volume
        breakTickPlayer.volume = volume
    }
    
    func setTick(task:Pomodoro) {
        let tickValue = userDefaults.boolForKey(Constants.UserDefaultKeys.kTick)
        if tickValue == false { return }
        
        switch task.type {
        case .Task:
//            if task.time > 60 {
//                if breakTickPlayer.playing { breakTickPlayer.stop() }
//                if taskTickRushPlayer.playing { taskTickRushPlayer.stop() }
//                if taskTickPlayer.playing == false {
//                    taskTickPlayer.play()
//                }
            currentTickPlayer = taskTickPlayer
//            } else {
//                if taskTickPlayer.playing { taskTickPlayer.stop() }
//                if taskTickRushPlayer.playing == false {
//                    taskTickRushPlayer.play()
//                }
//            }
            
        default:
//            if taskTickPlayer.playing { taskTickPlayer.stop() }
//            if taskTickRushPlayer.playing { taskTickRushPlayer.stop() }
//            breakTickPlayer.play()
            currentTickPlayer = breakTickPlayer
        }
        
        playTick()
    }
    
    func playTick () {
        if let player = currentTickPlayer {
            player.play()
            
        }
    }
    
    func stopTick() {
        if let player = currentTickPlayer {
            player.stop()
        }
    }
    
    func playChime() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let chimeValue = userDefault.boolForKey("chime_preference")
        if chimeValue == false { return }
        
        minuteBellPlayer.play()
    }
    
    func playAlarm() {
        let userDefault = NSUserDefaults.standardUserDefaults()
        let alarmValue = userDefault.boolForKey("alarm_preference")
        if alarmValue == false { return }
        
        timeoutBellPlayer.play()
    }
}
