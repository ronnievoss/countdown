//
//  EventDetailsInterfaceController.swift
//  Countdown
//
//  Created by Ronnie Voss on 5/3/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import WatchKit
import Foundation


class EventDetailsInterfaceController: WKInterfaceController {
    
    // MARK: Outlets
    
    @IBOutlet var eventTitleLabel: WKInterfaceLabel!
    @IBOutlet weak var counterDaysLabel: WKInterfaceLabel!
    @IBOutlet weak var counterHoursLabel: WKInterfaceLabel!
    @IBOutlet weak var counterMinutesLabel: WKInterfaceLabel!
    @IBOutlet weak var counterSecondsLabel: WKInterfaceLabel!
    
    var timer = Timer()
    var timeLeft:TimeInterval!
    var eventTitle:String!
    var eventDate:Date!

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if let event = context as? [String: AnyObject]{
            eventTitle = event["eventName"]! as? String
            eventDate = event["eventDate"]! as? Date
            eventTitleLabel.setText(eventTitle)
        }
        updateLabels()
        startCounter()
    }
    
    @objc func updateLabels() {
        timeLeft = eventDate.timeIntervalSinceNow
        let day = Int((timeLeft/86400))
        let hour = Int((timeLeft/3600.0).truncatingRemainder(dividingBy: 24))
        let minute = Int((timeLeft/60.0).truncatingRemainder(dividingBy: 60))
        let second = Int((timeLeft).truncatingRemainder(dividingBy: 60))
        counterDaysLabel.setText(String(day))
        counterHoursLabel.setText(String(hour))
        counterMinutesLabel.setText(String(minute))
        counterSecondsLabel.setText(String(second))
    }
    
    func startCounter() {
        if timeLeft <= 0 {
            counterDaysLabel.setText("0")
            counterHoursLabel.setText("0")
            counterMinutesLabel.setText("0")
            counterSecondsLabel.setText("0")
            timer.invalidate()
            let alert = WKAlertAction(title: "OK", style: WKAlertActionStyle.default, handler: {
                () -> Void in
            })
            self.presentAlert(withTitle: "Countdown Completed", message: eventTitle, preferredStyle: WKAlertControllerStyle.alert, actions: [alert])
        } else {
            timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(EventDetailsInterfaceController.updateLabels), userInfo: nil, repeats: true)
        }
    }
    

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
