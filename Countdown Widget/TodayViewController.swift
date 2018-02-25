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
    var date = [Date]()
    var timer = Timer()
    var eventTitle:String!
    var eventDate:Date!
    var timeLeft:TimeInterval!
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        events = event.userDefaults!.object(forKey: "events") as? [String] ?? [String]()
        date = event.userDefaults!.object(forKey: "date") as? [Date] ?? [Date]()
        
        if events.count > 0 {
            loadEvent()
        } else {
            stackView.isHidden = true
            noEventsLabel.isHidden = false
        }
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadEvent() {
        stackView.isHidden = false
        noEventsLabel.isHidden = true
        
        let index: Int? = event.userDefaults!.integer(forKey: "index")
        
        if let arrayIndex = index {
            eventTitle = events[arrayIndex]
            eventDate = date[arrayIndex]
            eventLabel.text = eventTitle
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateFormatter.timeStyle = .short
        }
        
        updateLabels()
        startCounter()
    }
    
    func updateLabels() {
        timeLeft = eventDate.timeIntervalSinceNow
        let day = Int((timeLeft/86400))
        let hour = Int((timeLeft/3600.0).truncatingRemainder(dividingBy: 24))
        let minute = Int((timeLeft/60.0).truncatingRemainder(dividingBy: 60))
        let second = Int((timeLeft).truncatingRemainder(dividingBy: 60))
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
        timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(TodayViewController.updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounter() {
        
        if timeLeft <= 0 {
            timer.invalidate()
        } else {
            updateLabels()
        }
    }
    
    func widgetPerformUpdate(completionHandler: @escaping ((NCUpdateResult) -> Void)) {
        
        if events.count > 0 {
            loadEvent()
            completionHandler(NCUpdateResult.newData)
        } else {
            completionHandler(NCUpdateResult.noData)        }
        
        
    }
    
    func widgetMarginInsets
        (forProposedMarginInsets defaultMarginInsets: UIEdgeInsets) -> (UIEdgeInsets) {
        return UIEdgeInsets.zero
    }
}
