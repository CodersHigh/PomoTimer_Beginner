//
//  AppDelegate.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 4. 13..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        serializeLoad()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        serializeSave()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        serializeSave()
    }

    func serializeSave() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let todayKeyString : String = dateToString(NSDate())
        if var historyDictionary = defaults.dictionaryForKey("History") as? [String:[String:Int]]{
            historyDictionary[todayKeyString] = todayPomodoroInfo()
            defaults.setObject(historyDictionary, forKey: "History")
            println("Exist Saved = \(historyDictionary[todayKeyString])")
        } else {
            var historyDictionary:[String:[String:Int]] = [:]
            let info:[String:Int] = todayPomodoroInfo()
            historyDictionary[todayKeyString] = info
            defaults.setObject(historyDictionary, forKey: "History")
            println("Newly Saved = \(historyDictionary[todayKeyString])")
        }
        
        
        defaults.synchronize()
    }
    
    func serializeLoad() {
        let defaults = NSUserDefaults.standardUserDefaults()
        let todayKeyString : String = dateToString(NSDate())
        if let historyDictionary = defaults.dictionaryForKey("History") as? [String:[String:Int]]{
            if let todayPomodoro = historyDictionary[todayKeyString] {
                println("Loaded = \(todayPomodoro)")
                setTodayPomodoro(todayPomodoro)
            }
        }
    }
    
    func todayPomodoroInfo () -> [String:Int] {
        let taskVC = window?.rootViewController as TaskViewController
        var infoDictionary:[String:Int] = [:]
        infoDictionary["Cycles"] = taskVC.todays.count - 1
        infoDictionary["Tasks"] = taskVC.todays.last?.doneTasks.count
        return infoDictionary
    }
    
    func setTodayPomodoro (infoDict:[String:Int]) {
        let cycles:Int = infoDict["Cycles"] as Int!
        let tasks:Int = infoDict["Tasks"] as Int!
        var todaysPomodoro = [Cycle](count: cycles, repeatedValue: Cycle(done: true))
        let currentCycle = Cycle()
        if tasks > 0 {
            for index in 0...(tasks + (tasks - 1)) {
                let pomodoro = currentCycle.pomodoroArray[index]
                pomodoro.status = .DONE
                pomodoro.time = 0
            }
        }
        todaysPomodoro += [currentCycle]
        
        let taskVC = window?.rootViewController as TaskViewController
        taskVC.todays = todaysPomodoro
        taskVC.currentCycle = currentCycle
        //taskVC.updateUI()
    }
}

func dateToString(date : NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.stringFromDate(date)
}