//
//  EventsTableViewController.swift
//  Countdown
//
//  Created by Ronnie Voss on 4/27/16.
//  Copyright © 2016 Ronnie Voss. All rights reserved.
//

import UIKit
import WatchConnectivity
import EventKit

class EventsTableViewController: UITableViewController, WCSessionDelegate {
     
     var session: WCSession?
     var eventStore: EKEventStore!
     var calendarEvent: String?
     var calendarStartDate: NSDate?
     var calendarEndDate: NSDate?
     var allDayEvent: Bool?
     var event = Event()
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          if WCSession.isSupported() {
               session = WCSession.defaultSession()
               session?.delegate = self
               session?.activateSession()
          }
          
          sendApplicationContext()
          tableView.reloadData()
     }
     
     override func viewWillAppear(animated: Bool) {
          super.viewWillAppear(true)
          
          tableView.reloadData()
     }
     
     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }
     
     func sendApplicationContext() {
          if let validSession = session {
               let iPhoneAppContext = ["events": event.events, "date": event.date]
               do {
                    try validSession.updateApplicationContext(iPhoneAppContext as! [String : AnyObject])
               } catch {
                    print("Something went wrong")
               }
          }
     }
     
     // MARK: Table view data source
     
     override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
          
          if event.events.count > 0 {
               
               self.tableView.backgroundView = nil
               self.tableView.separatorStyle = UITableViewCellSeparatorStyle.SingleLine
               
          } else {
               
               let noDataLabel: UILabel = UILabel(frame: CGRectMake(0, 0, self.tableView.bounds.size.width, self.tableView.bounds.size.height))
               noDataLabel.font = UIFont.systemFontOfSize(50)
               noDataLabel.text = "No Events"
               noDataLabel.textColor = UIColor.darkGrayColor()
               noDataLabel.textAlignment = NSTextAlignment.Center
               self.tableView.backgroundView = noDataLabel
               self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
          }
          return 1
     }
     
     override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return event.events.count
     }
     
     
     override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
          
          let dateFormatter = NSDateFormatter()
          dateFormatter.dateStyle = .MediumStyle
          dateFormatter.timeStyle = .ShortStyle
          let selectedDate = dateFormatter.stringFromDate(event.date[indexPath.row])
          let timeLeft = event.date[indexPath.row].timeIntervalSinceNow
          
          if timeLeft <= 0 {
               cell.textLabel?.textColor = UIColor.redColor()
               cell.detailTextLabel?.textColor = UIColor.redColor()
          } else {
               cell.textLabel?.textColor = UIColor.blackColor()
               cell.detailTextLabel?.textColor = UIColor.blackColor()
          }
          
          cell.textLabel?.text = event.events[indexPath.row]
          cell.detailTextLabel?.text = selectedDate
          
          return cell
     }
     
     override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
          event.userDefaults!.setInteger(indexPath.row, forKey: "index")
     }
     
     
     override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
          // Return false if you do not want the specified item to be editable.
          return true
     }
     
     override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
          if editingStyle == .Delete {
               // Delete the row from the data source
               cancelLocalNotification(String(event.date[indexPath.row]))
               event.events.removeAtIndex(indexPath.row)
               event.date.removeAtIndex(indexPath.row)
               event.userDefaults!.setObject(event.events, forKey: "events")
               event.userDefaults!.setObject(event.date, forKey: "date")
               let index = event.userDefaults?.integerForKey("index")
               if index == indexPath.row {
                    event.userDefaults?.setInteger(0, forKey: "index")
               }
               
               tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
               sendApplicationContext()
          }
     }
     
     // MARK: Navigation
     
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
          if segue.identifier == "ShowDetail" {
               let selectedCell = sender as? UITableViewCell, selectedRowIndex = tableView.indexPathForCell(selectedCell!)!.row
               let eventName = event.events[selectedRowIndex]
               let eventDate = event.date[selectedRowIndex]
               let detailViewController = segue.destinationViewController as! ViewController
               detailViewController.eventTitle = eventName
               detailViewController.eventDate = eventDate
          }
     }
     
     @IBAction func cancelToEventsTableViewController(segue:UIStoryboardSegue) {
          
     }
     
     @IBAction func saveEvent(segue:UIStoryboardSegue) {
          if let addEventViewController = segue.sourceViewController as? AddEventViewController {
               if let eventName = addEventViewController.eventTextField.text {
                    event.events.append(eventName)
                    calendarEvent = eventName
                    event.userDefaults?.setObject(event.events, forKey: "events")
               }
               
               if let eventDate = addEventViewController.startDate {
                    event.date.append(eventDate)
                    calendarStartDate = eventDate
                    event.userDefaults?.setObject(event.date, forKey: "date")
                    self.localNotification(eventDate)
               }
               
               if addEventViewController.addToCalendarSwitch.on {
                    if addEventViewController.allDayEventSwitch.on {
                         allDayEvent = true
                    } else {
                         allDayEvent = false
                    }
                    
                    if let eventEndDate = addEventViewController.endDate {
                         calendarEndDate = eventEndDate
                    }
                    
                    if let alertTitle = addEventViewController.reminderDetailLabel.text {
                         
                         var dateOffset = NSTimeInterval()
                         
                         switch (alertTitle) {
                              
                         case "5 minutes":
                              dateOffset = (60 * 5)
                              
                         case "1 hour":
                              dateOffset = (60 * 60)
                              
                         case "1 day":
                              dateOffset = (60 * 60 * 24)
                              
                         default:
                              dateOffset = 0
                         }
                         
                         saveNewEvent(dateOffset)
                    }
               }
          }
          
          tableView.reloadData()
          sendApplicationContext()
     }
     
     func saveNewEvent(dateOffset: NSTimeInterval) {
          
          eventStore = EKEventStore()
          eventStore.requestAccessToEntityType(EKEntityType.Event) { (Granted, error) in
               
               if Granted {
                    let newEvent = EKEvent(eventStore: self.eventStore)
                    newEvent.title = self.calendarEvent!
                    newEvent.startDate = self.calendarStartDate!
                    newEvent.endDate = self.calendarEndDate!
                    newEvent.allDay = self.allDayEvent!
                    newEvent.calendar = self.eventStore.defaultCalendarForNewEvents
                    newEvent.addAlarm(EKAlarm(relativeOffset: -dateOffset))
                    
                    do {
                         try self.eventStore.saveEvent(newEvent, span: .ThisEvent)
                    }catch{
                         let ac = UIAlertController(title: "Cannot create event", message: "The start date must be before the end date", preferredStyle: .Alert)
                         ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                         self.presentViewController(ac, animated: true, completion: nil)
                    }
                    
               } else {
                    let ac = UIAlertController(title: "Need permission to access your calendar", message: "The app is not permitted to access your calendar, make sure to grant permission in the settings and try again", preferredStyle: .Alert)
                    ac.addAction(UIAlertAction(title: "Settings", style: .Default, handler: { action in
                         self.openSettings()
                    }))
                    ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(ac, animated: true, completion: nil)
               }
          }
     }
     
     func openSettings() {
          let url = NSURL(string: UIApplicationOpenSettingsURLString)
          UIApplication.sharedApplication().openURL(url!)
     }
     
     func localNotification(eventDate: NSDate) {
          
          guard let settings = UIApplication.sharedApplication().currentUserNotificationSettings() else { return }
          if settings.types == .None {
               let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .Alert)
               ac.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
               presentViewController(ac, animated: true, completion: nil)
               return
          }
          
          let notification = UILocalNotification()
          let dict:NSDictionary = ["ID": String(eventDate)]
          notification.fireDate = eventDate
          notification.userInfo = dict as! [String: AnyObject]
          notification.alertBody = event.events.last
          notification.alertAction = "Dismiss"
          notification.soundName = UILocalNotificationDefaultSoundName
          UIApplication.sharedApplication().scheduleLocalNotification(notification)
     }
     
     func cancelLocalNotification(uniqueID: String) {
          if let notifyArray = UIApplication.sharedApplication().scheduledLocalNotifications {
               for notification in notifyArray as [UILocalNotification] {
                    if let info = notification.userInfo as? [String: String] {
                         if info["ID"] == uniqueID {
                              UIApplication.sharedApplication().cancelLocalNotification(notification)
                         }
                    }
               }
          }
     }
     
     
}
