//
//  TodayViewController.swift
//  Countdown Widget
//
//  Created by Ronnie Voss on 5/16/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    
    var events = [String]()
    var date = [NSDate]()
    var timer = NSTimer()
    var eventTitle:String!
    var eventDate:NSDate!
    var timeLeft:NSTimeInterval!
    var event = Event()
    
    // MARK: Outlets
    
    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var counterDaysLabel: UILabel!
    @IBOutlet weak var counterHoursLabel: UILabel!
    @IBOutlet weak var counterMinutesLabel: UILabel!
    @IBOutlet weak var counterSecondsLabel: UILabel!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var noEventsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        events = event.userDefaults!.objectForKey("events") as? [String] ?? [String]()
        date = event.userDefaults!.objectForKey("date") as? [NSDate] ?? [NSDate]()
        
        if events.count > 0 {
            loadEvent()
        } else {
            stackView.hidden = true
            noEventsLabel.hidden = false
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadEvent() {
        stackView.hidden = false
        noEventsLabel.hidden = true
        
        let index: Int? = event.userDefaults!.integerForKey("index")
        
        if let arrayIndex = index {
            eventTitle = events[arrayIndex]
            eventDate = date[arrayIndex]
            eventLabel.text = eventTitle
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .MediumStyle
            dateFormatter.timeStyle = .ShortStyle
        }
        
        updateLabels()
        startCounter()
    }
    
    func updateLabels() {
        timeLeft = eventDate.timeIntervalSinceNow
        let day = Int((timeLeft/86400))
        let hour = Int((timeLeft/3600.0)%24)
        let minute = Int((timeLeft/60.0)%60)
        let second = Int((timeLeft)%60)
        counterDaysLabel.text = String(day)
        counterHoursLabel.text = String(hour)
        counterMinutesLabel.text = String(minute)
        counterSecondsLabel.text = String(second)
    }
    
    func startCounter() {
        if timeLeft <= 0 {
            counterDaysLabel.text = "0"
            counterHoursLabel.text = "0"
            counterMinutesLabel.text = "0"
            counterSecondsLabel.text = "0"
        }
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(TodayViewController.updateCounter), userInfo: nil, repeats: true)
    }
    
    func updateCounter() {
        
        if timeLeft <= 0 {
            timer.invalidate()
        } else {
            updateLabels()
        }
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)) {
        
        if events.count > 0 {
            loadEvent()
            completionHandler(NCUpdateResult.NewData)
        } else {
            completionHandler(NCUpdateResult.NoData)        }
        
        
    }
    
    func widgetMarginInsetsForProposedMarginInsets
        (defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsetsZero
    }
    
}
