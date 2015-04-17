//
//  HistoryTableViewController.swift
//  PomoTimerBeginner
//
//  Created by Lingostar on 2015. 4. 16..
//  Copyright (c) 2015년 Lingostar. All rights reserved.
//

import UIKit

struct HistoryData {
    var date:(year:Int, month:Int, day:Int) = (0,0,0)
    var dailyPomodoro:(cycle:Int, task:Int) = (0,0)
    var totalTask:Int { get{
        return dailyPomodoro.cycle*4 + dailyPomodoro.task
    }}
}

class HistoryTableViewController: UITableViewController {
    
    var historyData:[String:[HistoryData]] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHistoryData()
    }
    
    func loadHistoryData() {
        let defaults = NSUserDefaults.standardUserDefaults()
        //var _historyData:[String:[HistoryData]] = [:]
        if let historyDictionary = defaults.dictionaryForKey("History") as? [String:[String:Int]]{
            for (dateKey, tasksValue) in historyDictionary {
                var oneDayRecord = HistoryData()
                let dateArray:[String] = dateKey.componentsSeparatedByString("-") as [String]
                oneDayRecord.date = (dateArray[0].toInt()!, dateArray[1].toInt()!, dateArray[2].toInt()!)
                oneDayRecord.dailyPomodoro = (tasksValue["Cycles"]!, tasksValue["Tasks"]!)
                // dictionary이므로 "년-월"로 이루어진 키에 History데이터들의 어레이가 있는 방식으로 만듬.
                //년도를 따로 관리해서 합산을 하진 않음.
                //년-월로 키를 만들어서 만약 해당 키의 어레이가 있으면 더하고 없으면 어레이를 새로 만들어야 함.
                let keyString = "\(oneDayRecord.date.year)-\(oneDayRecord.date.month)"
                if var monthlyTask:[HistoryData] = historyData[keyString] {
                    monthlyTask += [oneDayRecord]
                } else {
                    var monthlyTask:[HistoryData] = [oneDayRecord]
                    historyData[keyString] = monthlyTask
                }
            }
        }
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
        
        let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as HistoryTableViewCell
        let keyArray:[String] = historyData.keys.array
        let monthlyTaskArray:[HistoryData] = historyData[keyArray[indexPath.section]]!
        let aDayRecord = monthlyTaskArray[indexPath.row]
        
        cell.dateLabel.text = "\(aDayRecord.date.day)일"
        cell.cycleButton.setTitle("\(aDayRecord.dailyPomodoro.cycle)", forState: .Normal)
        let task:Int = aDayRecord.dailyPomodoro.task
        if task > 0 {
            for index in 0...(task - 1) {
                cell.pomodoroImages[index].image = UIImage(named: Status.DONE.imageName)
            }
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let keyArray:[String] = historyData.keys.array
        return keyArray[section]
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