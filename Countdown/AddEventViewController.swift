//
//  AddEventViewController.swift
//  Countdown
//
//  Created by Ronnie Voss on 4/29/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import UIKit

class AddEventViewController: UITableViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {
    
    var event:String?
    var startDate:NSDate?
    var endDate:NSDate?
    var interval: NSTimeInterval?
    var datePickerHidden = true
    var startDatePickerHidden = true
    var endDatePickerHidden = true
    var reminder: String = "None" {
        didSet {
            reminderDetailLabel.text = reminder
        }
    }
    
    // MARK: Outlets

    @IBOutlet weak var eventTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var startDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var reminderDetailLabel: UILabel!
    @IBOutlet weak var allDayEventSwitch: UISwitch!
    @IBOutlet weak var addToCalendarSwitch: UISwitch!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventTextField.delegate = self
        eventTextField.becomeFirstResponder()
        valueChanged(startDatePicker)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    
    @IBAction func valueChanged(sender: UIDatePicker!) {
        let dateFormatter = NSDateFormatter()
        let endDateFormatter = NSDateFormatter()
        
        // Add 1 hour to end date
        self.interval = 3600
        if sender == startDatePicker {
            endDatePicker.setDate(startDatePicker.date.dateByAddingTimeInterval(interval!), animated: false)
        }
        
        startDate = startDatePicker.date
        endDate = endDatePicker.date

        if addToCalendarSwitch.on == true {
            dateLabel.text = "Starts"
        }
        
        //Check if startDatePicker and endDatePicker is same day
        let sameDay = NSCalendar.currentCalendar().isDate(startDate!, inSameDayAsDate: endDate!)
        
        if sameDay == true {
            endDateFormatter.dateFormat = "h:mm a"
        } else {
            endDateFormatter.dateFormat = "MMM d, yyyy       h:mm a"
        }
        
        if allDayEventSwitch.on {
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            endDateFormatter.dateFormat = "EEEE, MMM d, yyyy"
            if sender == startDatePicker {
                endDatePicker.setDate(startDatePicker.date, animated: false)
            }
        } else {
            dateFormatter.dateFormat = "MMM d, yyyy       h:mm a"
        }
        
        // Check if end date is earlier than start date
        let compareDate = startDate!.compare(endDate!)
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: endDateFormatter.stringFromDate(endDate!))
        attributeString.addAttribute(NSStrikethroughStyleAttributeName, value: 1, range: NSMakeRange(0, attributeString.length))
        
        startDateLabel.text = dateFormatter.stringFromDate(startDate!)
        if compareDate == .OrderedDescending {
            endDateLabel.attributedText = attributeString
        } else {
            endDateLabel.text = endDateFormatter.stringFromDate(endDate!)
        }
        
    }
    
    @IBAction func calendarSwitchValueChanged(sender: UISwitch) {
        UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            self.eventTextField.resignFirstResponder()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            },completion: nil)
        if sender.on {self.dateLabel.text = "Starts"} else {self.dateLabel.text = "Date"}
    }
    
    @IBAction func allDayEventSwitchValueChanged(sender: UISwitch) {
        if allDayEventSwitch.on {
            startDatePicker.datePickerMode = .Date
            endDatePicker.datePickerMode = .Date
            valueChanged(startDatePicker)
        } else {
            startDatePicker.datePickerMode = .DateAndTime
            endDatePicker.datePickerMode = .DateAndTime
            valueChanged(startDatePicker)
        }
    }
    
    @IBAction func unwindWithSelectedReminder(segue: UIStoryboardSegue) {
        if let reminderViewController = segue.sourceViewController as? ReminderViewController, selectedReminder = reminderViewController.selectedReminder {
             reminder = selectedReminder
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            UIView.animateWithDuration(0.2, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: {
                cell.selectedBackgroundView?.alpha = CGFloat(0)
                },completion: nil)
        }
        if indexPath.section == 1 && indexPath.row == 2 {
            startDatePickerHidden = !startDatePickerHidden
            if !endDatePickerHidden {
                endDatePickerHidden = true
            }
        } else if indexPath.section == 1 && indexPath.row == 4 {
            endDatePickerHidden = !endDatePickerHidden
            if !startDatePickerHidden {
                startDatePickerHidden = true
            }
        } else if indexPath.section == 1 && indexPath.row == 0 {
            if addToCalendarSwitch.on {
                addToCalendarSwitch.setOn(false, animated: true)
                calendarSwitchValueChanged(addToCalendarSwitch)
            } else {
                addToCalendarSwitch.setOn(true, animated: true)
                calendarSwitchValueChanged(addToCalendarSwitch)
            }
        } else if indexPath.section == 1 && indexPath.row == 1 {
            if allDayEventSwitch.on {
                allDayEventSwitch.setOn(false, animated: true)
            } else {
                allDayEventSwitch.setOn(true, animated: true)
            }
            allDayEventSwitchValueChanged(allDayEventSwitch)
        }
        toggleDatepicker()
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if !addToCalendarSwitch.on && indexPath.section == 1 && indexPath.row == 1 {return 0}
        if !addToCalendarSwitch.on && indexPath.section == 1 && indexPath.row == 4 {return 0}
        if !addToCalendarSwitch.on && indexPath.section == 1 && indexPath.row == 6 {return 0}
        if startDatePickerHidden && indexPath.section == 1 && indexPath.row == 3 {
            return 0
        } else if endDatePickerHidden && indexPath.section == 1 && indexPath.row == 5 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAtIndexPath: indexPath)
        }
    }

    func toggleDatepicker() {

        if !self.startDatePickerHidden {
            self.startDateLabel.textColor = UIColor.redColor()
            self.eventTextField.resignFirstResponder()
        } else {
            self.startDateLabel.textColor = UIColor.blackColor()
        }
        
        if !self.endDatePickerHidden {
            self.endDateLabel.textColor = UIColor.redColor()
            self.eventTextField.resignFirstResponder()
        } else {
            self.endDateLabel.textColor = UIColor.blackColor()
        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        saveButton.enabled = false
        textField.addTarget(self, action: #selector(AddEventViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
    }
    
    func checkValidEventName() {
        let text = eventTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    func textFieldDidChange(textField: UITextField) {
        checkValidEventName()
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // MARK: Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveEvent" {
            event = eventTextField.text
            startDate = startDatePicker.date
            endDate = endDatePicker.date
            reminder = reminderDetailLabel.text!
            _ = allDayEventSwitch
            _ = addToCalendarSwitch
        }
        
        if segue.identifier == "SetReminder" {
            if let reminderViewController = segue.destinationViewController as? ReminderViewController {
                reminderViewController.selectedReminder = reminder
            }
        }
    }

}
