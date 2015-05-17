//
//  HistoryTableViewController.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 4. 16..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import UIKit

let isAppStore = false

struct HistoryData: Comparable {
    var date:(year:Int, month:Int, day:Int) = (0,0,0)
    var dailyPomodoro:(cycle:Int, task:Int) = (0,0)
    var totalTask:Int { get{
        return dailyPomodoro.cycle*4 + dailyPomodoro.task
    }}
    var keyString:String { get{
        return "\(self.date.year)-\(self.date.month)"
    }}
    var dateValue:NSDate { get{
        var dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.dateFromString("\(date.year)-\(date.month)-\(date.day)")!
    }}
    var fullDateString:String { get{
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("history_year_month_day",comment: "")
        return dateFormatter.stringFromDate(dateValue)
    }}
    var yearMonthString:String { get {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = NSLocalizedString("history_year_month",comment: "")
        return dateFormatter.stringFromDate(dateValue)
    }}
}


func == (left: HistoryData, right:HistoryData) -> Bool {
    return (left.date.year == right.date.year) && (left.date.month == right.date.month) && (left.date.day == right.date.day)
}

func < (left: HistoryData, right:HistoryData) -> Bool {
    var rightIsBig = false
    if (left.date.year < right.date.year) {
        rightIsBig = true
    } else if (left.date.year == right.date.year) {
        if (left.date.month < right.date.month) {
            rightIsBig = true
        } else if (left.date.month == right.date.month) {
            if (left.date.day < right.date.day) {
                rightIsBig = true
            }
        }
    }
    return rightIsBig
}



class HistoryTableViewController: UITableViewController {
    
    @IBOutlet weak var daysLabel: UILabel!
    @IBOutlet weak var pomodorosLabel: UILabel!
    
    
    //var duration:(startyear:Int, startmonth:Int, endyear:Int, endmonth:Int) = (0,0,0,0)
    var historyData:[String:[HistoryData]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHistoryData()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        let historyDataArray:[[HistoryData]] = historyData.values.array
        let flatHistoryArray = historyDataArray.reduce([], combine: +)
        var daysString : String = ""
        if let historyMinMax = minMax(flatHistoryArray) {
            let fromString = historyMinMax.min.fullDateString
            let toString = historyMinMax.max.fullDateString
            daysString = fromString + " ~ " + toString
        }
        
        let totalPomodoroArray = flatHistoryArray.map({$0.totalTask})
        let numberOfPomodoros = totalPomodoroArray.reduce(0, combine: +)
        let pomodorosString = totalDescriptionAttrString(numberOfPomodoros, fontSize: 14.0)
        
        daysLabel.text = daysString
        pomodorosLabel.attributedText = pomodorosString
    }
    
    func loadHistoryData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        if let historyDictionary = defaults.dictionaryForKey("History") as? [String:[String:Int]]{
        //if let historyDictionary = historyDummy(){
            for (dateKey, tasksValue) in historyDictionary {
                var oneDayRecord = HistoryData()
                let dateArray:[String] = dateKey.componentsSeparatedByString("-") as [String]
                oneDayRecord.date = (dateArray[0].toInt()!, dateArray[1].toInt()!, dateArray[2].toInt()!)
                oneDayRecord.dailyPomodoro = (tasksValue["Cycles"]!, tasksValue["Tasks"]!)

                if isAppStore {
                    if validateData(oneDayRecord) {
                        addToMonthDictionary(oneDayRecord)
                    }
                } else {
                    addToMonthDictionary(oneDayRecord)
                }
            }
        }
    }
    
    func addToMonthDictionary(data:HistoryData) {
        // dictionary이므로 "년-월"로 이루어진 키에 History데이터들의 어레이가 있는 방식으로 만듬.
        //년도를 따로 관리해서 합산을 하진 않음.
        //년-월로 키를 만들어서 만약 해당 키의 어레이가 있으면 더하고 없으면 어레이를 새로 만들어야 함.
        
        let keyString = data.keyString
        if var monthlyTask:[HistoryData] = historyData[keyString] {
            monthlyTask += [data]
            let sortedTask = monthlyTask.sorted({$0.date.day < $1.date.day})
            historyData[keyString] = sortedTask
        } else {
            var monthlyTask:[HistoryData] = [data]
            historyData[keyString] = monthlyTask
        }
    }
    
    func minMax (array : [HistoryData]) -> (min:HistoryData, max:HistoryData)? {
        if array.isEmpty { return nil }
        var min = array[0]
        var max = array[0]
        for history in array {
            if history < min { min = history }
            else if history > max { max = history }
        }
        
        return (min, max)
    }
    
    func historyDummy() -> [String:[String:Int]]? {
        let historyDictionary = ["2015-02-27":["Cycles":0,"Tasks":3], "2015-02-28":["Cycles":1,"Tasks":2], "2015-03-28":["Cycles":1,"Tasks":1], "2015-03-29":["Cycles":1,"Tasks":2],"2015-03-30":["Cycles":1,"Tasks":3], "2015-03-31":["Cycles":2,"Tasks":3], "2015-04-01":["Cycles":2,"Tasks":1], "2015-04-02":["Cycles":1,"Tasks":3],"2015-04-03":["Cycles":1,"Tasks":1], "2015-04-04":["Cycles":1,"Tasks":3]]
        
        return historyDictionary
    }
    

    
    func totalDescriptionAttrString(pomodoro:Int, fontSize:CGFloat) -> NSAttributedString {
        var descString = NSMutableAttributedString()
        
        let boldFont = UIFont.boldSystemFontOfSize(fontSize)
        let normalFont = UIFont.systemFontOfSize(fontSize)
        let lightFont = UIFont(name:"HelveticaNeue-Light", size: fontSize)
        
        let boldAttribute = [NSFontAttributeName:boldFont]
        let normalAttribute = [NSFontAttributeName:normalFont]
        let lightAttribute = [NSFontAttributeName:lightFont]
        

        descString.appendAttributedString(NSAttributedString(string:"\(pomodoro)", attributes: boldAttribute))
        let pomodoroString = NSLocalizedString("history_pomodoro", comment:"")
        descString.appendAttributedString(NSAttributedString(string:"\(pomodoroString) (", attributes: normalAttribute))
        descString.appendAttributedString(NSAttributedString(string:"\(pomodoro/4)", attributes: boldAttribute))
        descString.appendAttributedString(NSAttributedString(string:" + ", attributes: normalAttribute))
        descString.appendAttributedString(NSAttributedString(string:"\(pomodoro%4)", attributes: boldAttribute))
        descString.appendAttributedString(NSAttributedString(string:"), ", attributes: normalAttribute))
        descString.appendAttributedString(NSAttributedString(string:"\(pomodoro*25)", attributes: boldAttribute))
        let minuteString = NSLocalizedString("history_minute", comment:"")
        descString.appendAttributedString(NSAttributedString(string:"\(minuteString)", attributes: normalAttribute))
        return descString
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let sections:Int = historyData.keys.array.count
        return sections
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let keyArray:[String] = historyData.keys.array
        let monthlyTaskArray:[HistoryData] = historyData[keyArray[section]]!
        return monthlyTaskArray.count
    }
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as! HistoryTableViewCell
        let keyArray:[String] = historyData.keys.array
        let monthlyTaskArray:[HistoryData] = historyData[keyArray[indexPath.section]]!
        let aDayRecord = monthlyTaskArray[indexPath.row]
        
        cell.dateLabel.text = String(format: NSLocalizedString("history_day", comment:""), aDayRecord.date.day)
        cell.cycleButton.setTitle("\(aDayRecord.dailyPomodoro.cycle)", forState: .Normal)
        let task:Int = aDayRecord.dailyPomodoro.task
        if task > 0 {
            for index in 0...(task - 1) {
                cell.pomodoroImages[index].image = UIImage(named: Status.DONE.imageName)
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let keyArray:[String] = historyData.keys.array
        let monthlyHistory:[HistoryData] = historyData[keyArray[section]]!
        let monthlyTasks = monthlyHistory.map({$0.totalTask})
        let monthlyTotal = monthlyTasks.reduce(0, combine: +)
        let yearMonthString = monthlyHistory.first?.yearMonthString
        
        let customViews = UINib(nibName: "CustomViews", bundle: nil).instantiateWithOwner(nil, options: nil)
        let sectionHeader:UIView = customViews.first as! UIView
        let sectionHmonthLabel = sectionHeader.viewWithTag(111) as! UILabel
        let sectionHdescLabel = sectionHeader.viewWithTag(112) as! UILabel
        
        sectionHmonthLabel.text = yearMonthString
        sectionHdescLabel.attributedText = totalDescriptionAttrString(monthlyTotal, fontSize:12.0)
        
        return sectionHeader
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25.0
    }
    
    @IBAction func dismiss(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}



class HistoryTableViewCell: UITableViewCell {
    
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cycleButton: CircleButton!
    @IBOutlet var pomodoroImages: [UIImageView]!
    
}