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
        
        let isFirstLaunch: Bool = NSUserDefaults.standardUserDefaults().boolForKey("setting_copied")
        if isFirstLaunch == false {
            registerDefaultsFromSettings()
            NSUserDefaults.standardUserDefaults().setBool(true , forKey: "setting_copied")
        }
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
        
        //환경설정 읽어서 반영하기 (오디오 처리 등)
        NSUserDefaults.standardUserDefaults().synchronize()
        let defaults = NSUserDefaults.standardUserDefaults()
        let tick = defaults.boolForKey("tick_preference")
        println("tick = \(tick)")
        let tickBkg = defaults.boolForKey("tick_bkg_preference")
        println("tickBkg = \(tickBkg)")
        let chime = defaults.boolForKey("chime_preference")
        println("chime = \(chime)")
        let alarm = defaults.boolForKey("alarm_preference")
        println("alarm = \(alarm)")
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        serializeSave()
    }

    func registerDefaultsFromSettings() {
        var settingsBundle = NSBundle.mainBundle().pathForResource("Settings", ofType: "bundle")
        if settingsBundle == nil {
            println("Could not find Settings.bundle")
            return
        }
        var settings = NSDictionary(contentsOfFile:settingsBundle!.stringByAppendingPathComponent("Root.plist"))!
        var preferences: [NSDictionary] = settings.objectForKey("PreferenceSpecifiers") as [NSDictionary];
        var defaultsToRegister = NSMutableDictionary(capacity:(preferences.count));
        
        for prefSpecification:NSDictionary in preferences {
            if let key = prefSpecification.objectForKey("Key") as? NSCopying {
                defaultsToRegister.setObject(prefSpecification.objectForKey("DefaultValue")!, forKey: key)
            }
        }
            
        NSUserDefaults.standardUserDefaults().registerDefaults(defaultsToRegister);
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    //Tuple이 바로 저장되지 않기 때문에 [NSObject:AnyObject]의 NSDictionary로 저장.
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
    
    //MARK: iCloud Key-Value
    func updateToiCloud(notificationObject: NSNotification) {
        let dict:NSDictionary = NSUserDefaults.standardUserDefaults().dictionaryRepresentation()
        
        dict.enumerateKeysAndObjectsUsingBlock({key, value, stop in
            var newKey = key as NSString
            NSUbiquitousKeyValueStore.defaultStore().setObject(value, forKey: newKey)
        })
        
        NSUbiquitousKeyValueStore.defaultStore().synchronize()
    }
    
    func updateFromiCloud(notificationObject: NSNotification) {
        let iCloudStore = NSUbiquitousKeyValueStore.defaultStore()
        let dict: NSDictionary = iCloudStore.dictionaryRepresentation
        
        // prevent NSUserDefaultsDidChangeNotification from being posted while we update from iCloud
        NSNotificationCenter.defaultCenter().removeObserver(self, name:NSUserDefaultsDidChangeNotification, object:nil)
        
        dict.enumerateKeysAndObjectsUsingBlock({key, value, stop in
            var newKey = key as NSString
            
            NSUserDefaults.standardUserDefaults().setObject(value, forKey:newKey)
        })
        
        NSUserDefaults.standardUserDefaults().synchronize()
        
        // enable NSUserDefaultsDidChangeNotification notifications again
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"updateToiCloud:", name:NSUserDefaultsDidChangeNotification, object:nil)
        NSNotificationCenter.defaultCenter().postNotificationName("iCloudSyncDidUpdateToLatest", object:nil)
    }
    
    func startiCloudSync() {
        if ((NSClassFromString("NSUbiquitousKeyValueStore")) != nil) {
            if NSFileManager.defaultManager().ubiquityIdentityToken != nil {
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateFromiCloud:", name: NSUbiquitousKeyValueStoreDidChangeExternallyNotification, object: nil)
                NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateToiCloud:", name: NSUserDefaultsDidChangeNotification, object: nil)
            } else {
                println("iCloud Not Enabled")
            }
        } else {
            println("Not an iOS 6 or higher device")
        }
    }
}

func dateToString(date : NSDate) -> String {
    let dateFormatter = NSDateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.stringFromDate(date)
}
