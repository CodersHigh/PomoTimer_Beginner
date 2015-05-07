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
    
    override func viewDidLoad() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "batteryStateChanged:", name: UIDeviceBatteryStateDidChangeNotification, object: nil)
    }
    
    let userDefaults = NSUserDefaults.standardUserDefaults()
    
    @IBOutlet weak var tickSoundSwitch: UISwitch!
    @IBOutlet weak var tickInBackgroundSwitch: UISwitch!
    @IBOutlet weak var tickVolumeLabel: UILabel!
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
            userDefaults.setFloat(Float(stepper.value), forKey: Constants.UserDefaultKeys.kTickVolume)
            tickVolumeLabel.text = "\(stepper.value)"
        }
    }

    //MARK: Alarm
    @IBOutlet weak var alarmSoundSwitch: UISwitch!
    @IBOutlet weak var oneMinSwitch: UISwitch!
    @IBOutlet weak var alarmVolumeLabel: UILabel!
    
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
            userDefaults.setFloat(Float(stepper.value), forKey: Constants.UserDefaultKeys.kAlarmVolume)
            alarmVolumeLabel.text = "\(stepper.value)"
        }
    }
    
    //MARK: Screen
    @IBOutlet weak var screenSleepSwitch: UISwitch!
    @IBAction func screenSleepChanged(sender: AnyObject) {
        userDefaults.setBool(screenSleepSwitch.on, forKey: Constants.UserDefaultKeys.kSleep)
        UIApplication.sharedApplication().idleTimerDisabled = !(screenSleepSwitch.on)
    }
    
    @IBAction func done(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
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
}