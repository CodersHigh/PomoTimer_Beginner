//
//  Pomodoro.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 4. 13..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import Foundation
enum PomoType {
    case Task
    case SBreak
    case LBreak
    
    var initialTime : Int { get {
        switch self {
        case .Task : return 25 * 60
        case .SBreak : return 5 * 60
        case .LBreak : return 30 * 60
        }
    }}
}

enum Status : Int {
    case READY = 0, COUNTING, PAUSE, DONE
    var imageName : String { get {
        switch self {
        case .READY : return "Pomodoro_Dimmed"
        case .COUNTING : return "Pomodoro_On"
        case .PAUSE : return "Pomodoro_Off"
        case .DONE : return "Pomodoro_On"
        }
    }}
}

var audioPlayer = PomoAudioPlayer()
class Pomodoro : NSObject {
//struct Pomodoro {
    //static var taskTimer : NSTimer?
    
    var time : Int {
        didSet {
            if time == 60 { audioPlayer.playChime() }
            if time < 0 { status = .DONE }
        }
    }

    var type : PomoType
    
    var status : Status {
        didSet {
            switch status {
                case .COUNTING:
                    audioPlayer.setTick(self)
                    if oldValue == .READY { self.startDate = NSDate() }
                case .PAUSE:
                    audioPlayer.clearTick()
                case .DONE:
                    if oldValue == .COUNTING {
                        self.endDate = NSDate()
                        audioPlayer.clearTick()
                        audioPlayer.playAlarm()
                    }
                default: ()
            }
        }
    }
    
    var timeString : String { get{
        let minute:Int = time/60
        let second:Int = time%60
        let _timeString = String(format: "%.2d:%.2d", minute, second)
        return _timeString
    }}
    
    var startDate:NSDate?
    var endDate:NSDate?
    
    init(type : PomoType) {
        self.status = .READY
        self.type = type
        self.time = type.initialTime
    }
    
    func progress() {
        /*if status == .COUNTING {
            if (time > 0) {
                time--
            } else {
                status = .DONE
            }
        }*/
    }
    
}



class Cycle : NSObject {
//struct Cycle {
    var pomodoroArray : [Pomodoro]
//    var currentTask :Pomodoro? {
//        get {
//            
//        }
//    }
    override init () {
        pomodoroArray = [Pomodoro(type:.Task), Pomodoro(type:.SBreak), Pomodoro(type:.Task), Pomodoro(type:.SBreak), Pomodoro(type:.Task), Pomodoro(type:.SBreak), Pomodoro(type:.Task), Pomodoro(type:.LBreak),]
    }
    
    convenience init(done:Bool) {
        self.init()
        for pomodoro in pomodoroArray {
            pomodoro.status = .DONE
            pomodoro.time = 0
        }
    }
    
    var tasks : [Pomodoro] {  get {
        let taskArray = pomodoroArray.filter({$0.type == .Task})
        return taskArray
    }}
    
    var doneTasks : [Pomodoro] { get {
        let _doneTasks = tasks.filter({$0.status == .DONE})
        return _doneTasks
    }}
    
    var activePomodoros : [Pomodoro] { get {
        let actives = pomodoroArray.filter({$0.status != .DONE})
        return actives
    }}
    
    var _currentTask:Pomodoro?
    var currentTask : Pomodoro? { get {
        if let task = _currentTask {
            if task.status != .DONE { return task }
        }
        if let nextTask = activePomodoros.first {
            _currentTask = nextTask
            return nextTask
        }
        
        return nil
    }}
    
    var indexOfCurrentTask:Int? { get {
        if let currTask = currentTask {
            return find(tasks, currTask)
        }
        return nil
    }}
    
    func progress() {
        if let currTask = currentTask {
            if currTask.status == .PAUSE {
                return
            } else if currTask.status == .READY {
                currTask.status = .COUNTING
            }
            
            if (currTask.time >= 0) {
                currTask.time--
            }
        }
    }
    
    func start() {
        if let currTask = currentTask {
            currTask.status = .COUNTING
        }
    }
    
    func stop() {
        if let currTask = currentTask {
            currTask.status = .PAUSE
        }
    }
    
    func resetTask() {
        if let currTask = currentTask {
            currTask.status = .READY
            currTask.time = currTask.type.initialTime
        }
    }
}






