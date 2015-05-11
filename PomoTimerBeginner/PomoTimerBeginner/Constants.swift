//
//  Constants.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 5. 6..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import Foundation

struct Constants{
    struct UserDefaultKeys {
        static let AppEnterBkgDate = "AppEnterBackgroundDate"
        static let AppTerminateDate = "AppTerminateDate"
        static let kTick = "tick_preference"
        static let kTickBackground = "tick_bkg_preference"
        static let kTickVolume = "tick_volume_preference"
        static let kChime = "chime_preference"
        static let kAlarm = "alarm_preference"
        static let kAlarmVolume = "alarm_volume_preference"
        static let kSleep = "sleep_preference"
    }
    
    struct Encoding {
//        static let StartTime = "startTime"

    }
    
    struct Path {
        static let Documents = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        static let Temp = NSTemporaryDirectory()
//        static let DataFile = (NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as String) + "/sharedData.lvcdr"
    }
    
    struct Notification {
        static let DocumentUpdatedNotification = "DocumentUpdatedNotification"
    }
}