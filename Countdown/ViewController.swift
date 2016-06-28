//
//  ViewController.swift
//  Countdown
//
//  Created by Ronnie Voss on 4/15/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // MARK: Outlets

    @IBOutlet weak var eventLabel: UILabel!
    @IBOutlet weak var counterDaysLabel: UILabel!
    @IBOutlet weak var counterHoursLabel: UILabel!
    @IBOutlet weak var counterMinutesLabel: UILabel!
    @IBOutlet weak var counterSecondsLabel: UILabel!
    
    var eventTitle:String!
    var eventDate:NSDate!
    var timeLeft:NSTimeInterval!
    var timer = NSTimer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateLabels()
        startCounter()
        eventLabel.text = eventTitle
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
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target:self, selector: #selector(self.updateCounter), userInfo: nil, repeats: true)
    }
    
    @objc func updateCounter() {
        if timeLeft <= 0 {
            timer.invalidate()
            let ac = UIAlertController(title: eventTitle, message: "Countdown Completed", preferredStyle: .Alert)
            ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(ac, animated: true, completion: nil)
        } else {
            updateLabels()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
