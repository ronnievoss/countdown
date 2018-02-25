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
    var startDate:Date?
    var endDate:Date?
    var interval: TimeInterval?
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
    
    @IBAction func valueChanged(_ sender: UIDatePicker!) {
        let dateFormatter = DateFormatter()
        let endDateFormatter = DateFormatter()
        
        // Add 1 hour to end date
        self.interval = 3600
        if sender == startDatePicker {
            endDatePicker.setDate(startDatePicker.date.addingTimeInterval(interval!), animated: false)
        }
        
        startDate = startDatePicker.date
        endDate = endDatePicker.date

        if addToCalendarSwitch.isOn == true {
            dateLabel.text = "Starts"
        }
        
        //Check if startDatePicker and endDatePicker is same day
        let sameDay = Calendar.current.isDate(startDate!, inSameDayAs: endDate!)
        
        if sameDay == true {
            endDateFormatter.dateFormat = "h:mm a"
        } else {
            endDateFormatter.dateFormat = "MMM d, yyyy       h:mm a"
        }
        
        if allDayEventSwitch.isOn {
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
        let attributeString: NSMutableAttributedString = NSMutableAttributedString(string: endDateFormatter.string(from: endDate!))
        attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
        
        startDateLabel.text = dateFormatter.string(from: startDate!)
        if compareDate == .orderedDescending {
            endDateLabel.attributedText = attributeString
        } else {
            endDateLabel.text = endDateFormatter.string(from: endDate!)
        }
        
    }
    
    @IBAction func calendarSwitchValueChanged(_ sender: UISwitch) {
        UIView.animate(withDuration: 0.2, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
            self.eventTextField.resignFirstResponder()
            self.tableView.beginUpdates()
            self.tableView.endUpdates()
            },completion: nil)
        if sender.isOn {self.dateLabel.text = "Starts"} else {self.dateLabel.text = "Date"}
    }
    
    @IBAction func allDayEventSwitchValueChanged(_ sender: UISwitch) {
        if allDayEventSwitch.isOn {
            startDatePicker.datePickerMode = .date
            endDatePicker.datePickerMode = .date
            valueChanged(startDatePicker)
        } else {
            startDatePicker.datePickerMode = .dateAndTime
            endDatePicker.datePickerMode = .dateAndTime
            valueChanged(startDatePicker)
        }
    }
    
    @IBAction func unwindWithSelectedReminder(_ segue: UIStoryboardSegue) {
        if let reminderViewController = segue.source as? ReminderViewController, let selectedReminder = reminderViewController.selectedReminder {
             reminder = selectedReminder
        }
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            UIView.animate(withDuration: 0.2, delay: 0.1, options: UIViewAnimationOptions.curveEaseIn, animations: {
                cell.selectedBackgroundView?.alpha = CGFloat(0)
                },completion: nil)
        }
        if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 2 {
            startDatePickerHidden = !startDatePickerHidden
            if !endDatePickerHidden {
                endDatePickerHidden = true
            }
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 4 {
            endDatePickerHidden = !endDatePickerHidden
            if !startDatePickerHidden {
                startDatePickerHidden = true
            }
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 0 {
            if addToCalendarSwitch.isOn {
                addToCalendarSwitch.setOn(false, animated: true)
                calendarSwitchValueChanged(addToCalendarSwitch)
            } else {
                addToCalendarSwitch.setOn(true, animated: true)
                calendarSwitchValueChanged(addToCalendarSwitch)
            }
        } else if (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {
            if allDayEventSwitch.isOn {
                allDayEventSwitch.setOn(false, animated: true)
            } else {
                allDayEventSwitch.setOn(true, animated: true)
            }
            allDayEventSwitchValueChanged(allDayEventSwitch)
        }
        toggleDatepicker()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if !addToCalendarSwitch.isOn && (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 1 {return 0}
        if !addToCalendarSwitch.isOn && (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 4 {return 0}
        if !addToCalendarSwitch.isOn && (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 6 {return 0}
        if startDatePickerHidden && (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 3 {
            return 0
        } else if endDatePickerHidden && (indexPath as NSIndexPath).section == 1 && (indexPath as NSIndexPath).row == 5 {
            return 0
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
    }

    func toggleDatepicker() {

        if !self.startDatePickerHidden {
            self.startDateLabel.textColor = UIColor.red
            self.eventTextField.resignFirstResponder()
        } else {
            self.startDateLabel.textColor = UIColor.black
        }
        
        if !self.endDatePickerHidden {
            self.endDateLabel.textColor = UIColor.red
            self.eventTextField.resignFirstResponder()
        } else {
            self.endDateLabel.textColor = UIColor.black
        }
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
        
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
        textField.addTarget(self, action: #selector(AddEventViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
    }
    
    func checkValidEventName() {
        let text = eventTextField.text ?? ""
        saveButton.isEnabled = !text.isEmpty
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkValidEventName()
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
    
    
    // MARK: Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SaveEvent" {
            event = eventTextField.text
            startDate = startDatePicker.date
            endDate = endDatePicker.date
            reminder = reminderDetailLabel.text!
            _ = allDayEventSwitch
            _ = addToCalendarSwitch
        }
        
        if segue.identifier == "SetReminder" {
            if let reminderViewController = segue.destination as? ReminderViewController {
                reminderViewController.selectedReminder = reminder
            }
        }
    }

}
