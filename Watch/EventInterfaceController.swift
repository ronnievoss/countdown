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
    
    var session: WCSession?
    var events = [String]()
    var date = [Date]()
    var event = Event()
    
    // MARK: Outlets

    @IBOutlet var eventsTable: WKInterfaceTable!
    @IBOutlet var noDataLabel: WKInterfaceLabel!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            session = WCSession.default
            session?.delegate = self
            session?.activate()
        }
    }
    
    func loadEvents() {
        
        if events.count > 0 {
            
            self.noDataLabel.setHidden(true)
            
            for index in 0..<eventsTable.numberOfRows {
                if let controller = eventsTable.rowController(at: index) as? EventRowController {
                    controller.eventLabel.setText(events[index])
                    
                    let timeLeft = date[index].timeIntervalSinceNow
                    if timeLeft <= 0 {
                        controller.separator.setColor(UIColor.red)
                    } else {
                        controller.separator.setColor(UIColor.green)
                    }
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium
                    dateFormatter.timeStyle = .short
                    let selectedDate = dateFormatter.string(from: date[index])
                    controller.dateLabel.setText(selectedDate)
                }
            }
        } else {
            self.noDataLabel.setHidden(false)
        }
    }
    
    override func table(_ table: WKInterfaceTable, didSelectRowAt rowIndex: Int) {
        let eventTitle = events[rowIndex]
        let eventDate = date[rowIndex]
        self.pushController(withName: "Event", context: ["eventName": eventTitle, "eventDate": eventDate])
        event.userDefaults!.set(rowIndex, forKey: "index")
    }
    
    func processApplicationContext() {
        let iPhoneContext = session!.receivedApplicationContext as [String: Any]
            if iPhoneContext.isEmpty == false {
                events = iPhoneContext["events"]! as! [String]
                date = iPhoneContext["date"]! as! [Date]
                eventsTable.setNumberOfRows(events.count, withRowType: "EventRow")
            }
        
        self.loadEvents()
    }
    
    // MARK: WCSessionDelegate
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("session activation failed with error: \(error.localizedDescription)")
            return
        }
        
        print("session activated with state: \(activationState.rawValue)")
        processApplicationContext()
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        DispatchQueue.main.async {
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
