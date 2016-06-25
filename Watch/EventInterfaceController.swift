//
//  EventInterfaceController.swift
//  Countdown
//
//  Created by Ronnie Voss on 5/3/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity


class EventInterfaceController: WKInterfaceController, WCSessionDelegate {
    
    var events = [String]()
    var date = [NSDate]()
    var userDefaults = NSUserDefaults(suiteName: "group.com.rvoss.Countdown")

    @IBOutlet var eventsTable: WKInterfaceTable!
    @IBOutlet var noDataLabel: WKInterfaceLabel!
    
    let session = WCSession.defaultSession()
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        session.delegate = self
        session.activateSession()
        processApplicationContext()
        
    }
    
    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        let eventTitle = events[rowIndex]
        let eventDate = date[rowIndex]
        self.pushControllerWithName("Event", context: ["eventName": eventTitle, "eventDate": eventDate])
        
        userDefaults!.setObject(rowIndex, forKey: "index")
    }
    
    func processApplicationContext() {
        if let iPhoneContext = session.receivedApplicationContext as [String: AnyObject]? {
            if iPhoneContext.isEmpty == false {
                events = iPhoneContext["events"]! as! [String]
                date = iPhoneContext["date"]! as! [NSDate]
                eventsTable.setNumberOfRows(events.count, withRowType: "EventRow")
            }
        }
        
        if self.events.count > 0 {
            
            self.noDataLabel.setHidden(true)
            
            for index in 0..<eventsTable.numberOfRows {
                if let controller = eventsTable.rowControllerAtIndex(index) as? EventRowController {
                    controller.eventLabel.setText(events[index])
                    
                    let timeLeft = date[index].timeIntervalSinceNow
                    if timeLeft <= 0 {
                        controller.separator.setColor(UIColor.redColor())
                    } else {
                        controller.separator.setColor(UIColor.greenColor())
                    }
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .MediumStyle
                    dateFormatter.timeStyle = .ShortStyle
                    let selectedDate = dateFormatter.stringFromDate(date[index])
                    
                    controller.dateLabel.setText(selectedDate)
                }
            }
        } else {
            self.noDataLabel.setHidden(false)
        }
    }
    
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            self.processApplicationContext()
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        processApplicationContext()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
