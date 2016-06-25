//
//  ReminderViewController.swift
//  Countdown
//
//  Created by Ronnie Voss on 5/29/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import UIKit

class ReminderViewController: UITableViewController {

    var reminders = ["None", "5 minutes", "1 hour", "1 day"]
    
    var selectedReminder: String? {
        didSet {
            if let reminder = selectedReminder {
                selectedReminderIndex = reminders.indexOf(reminder)!
            }
        }
    }
    var selectedReminderIndex: Int?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

 
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        cell.textLabel?.text = reminders[indexPath.row]

        if indexPath.row == selectedReminderIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }
        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        if let index = selectedReminderIndex {
            let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: indexPath.section))
            cell?.accessoryType = .None
        }
        
        selectedReminder = reminders[indexPath.row]
        
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        cell?.accessoryType = .Checkmark
        
    }
    
    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveReminder" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPathForCell(cell)
                if let index = indexPath?.row {
                    selectedReminder = reminders[index]
                }
            }
        }
    }

}
