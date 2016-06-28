//
//  GlanceInterfaceController.swift
//  Countdown
//
//  Created by Ronnie Voss on 5/8/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class GlanceInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var events = [String]()
    var date = [NSDate]()
    var event = Event()
    
    // MARK: Outlets
    
    @IBOutlet var eventTitleLabel: WKInterfaceLabel!
    @IBOutlet var eventDateLabel: WKInterfaceLabel!
    @IBOutlet weak var counterDaysLabel: WKInterfaceLabel!
    @IBOutlet weak var counterHoursLabel: WKInterfaceLabel!
    @IBOutlet weak var counterMinutesLabel: WKInterfaceLabel!
    @IBOutlet weak var counterSecondsLabel: WKInterfaceLabel!
    
    let session = WCSession.defaultSession()
    
    var timer = NSTimer()
    var timeLeft:NSTimeInterval!
    var eventTitle:String!
    var eventDate:NSDate!

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        session.delegate = self
        session.activateSession()
        processApplicationContext()
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if events.count > 0 {
            let index: Int? = event.userDefaults!.integerForKey("index")
            
            if let arrayIndex = index {
                eventTitle = events[arrayIndex]
                eventDate = date[arrayIndex]
                eventTitleLabel.setText(eventTitle)
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .MediumStyle
                dateFormatter.timeStyle = .ShortStyle
                eventDateLabel.setText(dateFormatter.stringFromDate(eventDate))
            }
            updateLabels()
            startCounter()
        } else {
            eventTitleLabel.setText("No Events")
        }
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func updateLabels() {
        timeLeft = eventDate.timeIntervalSinceNow
        if timeLeft <= 0 {
            counterDaysLabel.setText("0")
            counterHoursLabel.setText("0")
            counterMinutesLabel.setText("0")
            counterSecondsLabel.setText("0")
            timer.invalidate()
        } else {
            let day = Int((timeLeft/86400))
            let hour = Int((timeLeft/3600.0)%24)
            let minute = Int((timeLeft/60.0)%60)
            let second = Int((timeLeft)%60)
            counterDaysLabel.setText(String(day))
            counterHoursLabel.setText(String(hour))
            counterMinutesLabel.setText(String(minute))
            counterSecondsLabel.setText(String(second))
        }
    }
    
    func startCounter() {
        if timeLeft <= 0 {
            counterDaysLabel.setText("0")
            counterHoursLabel.setText("0")
            counterMinutesLabel.setText("0")
            counterSecondsLabel.setText("0")
            timer.invalidate()
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(EventDetailsInterfaceController.updateLabels), userInfo: nil, repeats: true)
        }
    }
    
    func processApplicationContext() {
        if let iPhoneContext = session.receivedApplicationContext as [String: AnyObject]? {
            events = iPhoneContext["events"]! as? [String] ?? [String]()
            date = iPhoneContext["date"]! as! [NSDate]
        } else {return}
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            print("session called")
            self.processApplicationContext()
        }
    }

}
