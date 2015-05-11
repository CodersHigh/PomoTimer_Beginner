//
//  SettingsTableViewController.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 5. 6..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
    //MARK: Tick Sound
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "batteryStateChanged:", name: UIDeviceBatteryStateDidChangeNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tickSoundSwitch.on = userDefaults.boolForKey(Constants.UserDefaultKeys.kTick)
        tickInBackgroundSwitch.on = userDefaults.boolForKey(Constants.UserDefaultKeys.kTickBackground)
        let tickVolume = userDefaults.integerForKey(Constants.UserDefaultKeys.kTickVolume)
        let stepper = UIStepper()
        stepper.value = Double(tickVolume)
        tickVolumeChanged(stepper)
        
        alarmSoundSwitch.on = userDefaults.boolForKey(Constants.UserDefaultKeys.kAlarm)
        oneMinSwitch.on = userDefaults.boolForKey(Constants.UserDefaultKeys.kChime)
        let alarmVolume = userDefaults.integerForKey(Constants.UserDefaultKeys.kAlarmVolume)
        stepper.value = Double(alarmVolume)
        alarmVolumeChanged(stepper)
        
        screenSleepSwitch.on = userDefaults.boolForKey(Constants.UserDefaultKeys.kSleep)
    }
    
    @IBOutlet weak var tickSoundSwitch: UISwitch!
    @IBOutlet weak var tickInBackgroundSwitch: UISwitch!
    @IBOutlet weak var tickVolumeLabel: UILabel!
    @IBOutlet weak var tickVolumeStepper: UIStepper!
    
    @IBAction func tickSoundChanged(sender: AnyObject) {
        if let tickSwitch = sender as? UISwitch {
            userDefaults.setBool(tickSwitch.on, forKey: Constants.UserDefaultKeys.kTick)
        }
    }
    
    @IBAction func tickInBkgChanged(sender: AnyObject) {
        if let tickSwitch = sender as? UISwitch {
            userDefaults.setBool(tickSwitch.on, forKey: Constants.UserDefaultKeys.kTickBackground)
        }
    }
    
    @IBAction func tickVolumeChanged(sender: AnyObject) {
        if let stepper = sender as? UIStepper {
            userDefaults.setInteger(Int(stepper.value), forKey: Constants.UserDefaultKeys.kTickVolume)
            tickVolumeLabel.text = "\(Int(stepper.value))"
        }
    }

    //MARK: Alarm
    @IBOutlet weak var alarmSoundSwitch: UISwitch!
    @IBOutlet weak var oneMinSwitch: UISwitch!
    @IBOutlet weak var alarmVolumeLabel: UILabel!
    @IBOutlet weak var alarmVolumeStepper: UIStepper!
    
    @IBAction func alarmSoundChanged(sender: AnyObject) {
        if let alarmSwitch = sender as? UISwitch {
            userDefaults.setBool(alarmSwitch.on, forKey: Constants.UserDefaultKeys.kAlarm)
        }
    }
    
    @IBAction func oneMinChimeChanged(sender: AnyObject) {
        if let alarmSwitch = sender as? UISwitch {
            userDefaults.setBool(alarmSwitch.on, forKey: Constants.UserDefaultKeys.kChime)
        }
    }
    
    @IBAction func alarmVolumeChanged(sender: AnyObject) {
        if let stepper = sender as? UIStepper {
            userDefaults.setInteger(Int(stepper.value), forKey: Constants.UserDefaultKeys.kAlarmVolume)
            alarmVolumeLabel.text = "\(Int(stepper.value))"
        }
    }
    
    //MARK: Screen
    @IBOutlet weak var screenSleepSwitch: UISwitch!
    @IBAction func screenSleepChanged(sender: AnyObject) {
        userDefaults.setBool(screenSleepSwitch.on, forKey: Constants.UserDefaultKeys.kSleep)
        UIApplication.sharedApplication().idleTimerDisabled = !(screenSleepSwitch.on)
    }

    func batteryStateChanged(notification:NSNotification) {
        switch UIDevice.currentDevice().batteryState {
        case .Charging:
            UIApplication.sharedApplication().idleTimerDisabled = true
        default:
            let sleep = userDefaults.boolForKey(Constants.UserDefaultKeys.kSleep)
            UIApplication.sharedApplication().idleTimerDisabled = !sleep
        }
    }
    
    //MARK: ViewController Action
    @IBAction func done(sender: AnyObject) {
        updateUserDefaults()
        userDefaults.synchronize()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateUserDefaults () {
        userDefaults.setBool(tickSoundSwitch.on, forKey: Constants.UserDefaultKeys.kTick)
        userDefaults.setBool(tickInBackgroundSwitch.on, forKey: Constants.UserDefaultKeys.kTickBackground)
        userDefaults.setInteger(Int(tickVolumeStepper.value), forKey: Constants.UserDefaultKeys.kTickVolume)
        
        userDefaults.setBool(alarmSoundSwitch.on, forKey: Constants.UserDefaultKeys.kAlarm)
        userDefaults.setBool(oneMinSwitch.on, forKey: Constants.UserDefaultKeys.kChime)
        userDefaults.setInteger(Int(alarmVolumeStepper.value), forKey: Constants.UserDefaultKeys.kAlarmVolume)

        userDefaults.setBool(screenSleepSwitch.on, forKey: Constants.UserDefaultKeys.kSleep)
    }
    
}