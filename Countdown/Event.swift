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
    var date: [Date]
    let userDefaults = UserDefaults(suiteName: "group.com.rvoss.Countdown")
    
    init() {
        self.events = userDefaults!.object(forKey: "events") as? [String] ?? [String]()
        self.date = userDefaults!.object(forKey: "date") as? [Date] ?? [Date]()
    }
}
