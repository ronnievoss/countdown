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
                selectedReminderIndex = reminders.index(of: reminder)!
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

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminders.count
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = reminders[(indexPath as NSIndexPath).row]

        if (indexPath as NSIndexPath).row == selectedReminderIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        if let index = selectedReminderIndex {
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: (indexPath as NSIndexPath).section))
            cell?.accessoryType = .none
        }
        
        selectedReminder = reminders[(indexPath as NSIndexPath).row]
        
        let cell = tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
        
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SaveReminder" {
            if let cell = sender as? UITableViewCell {
                let indexPath = tableView.indexPath(for: cell)
                if let index = (indexPath as NSIndexPath?)?.row {
                    selectedReminder = reminders[index]
                }
            }
        }
    }

}
