//
//  Event.swift
//  Countdown
//
//  Created by Ronnie Voss on 6/26/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import UIKit


class Event {
    
    var events: [String]
    var date: [NSDate]
    let userDefaults = NSUserDefaults(suiteName: "group.com.rvoss.Countdown")
    
    init() {
        self.events = userDefaults!.objectForKey("events") as? [String] ?? [String]()
        self.date = userDefaults!.objectForKey("date") as? [NSDate] ?? [NSDate]()
    }
}
