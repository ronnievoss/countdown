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
import UserNotifications

class EventsTableViewController: UITableViewController, WCSessionDelegate {
     
     var session: WCSession?
     var eventStore: EKEventStore!
     var calendarEvent: String?
     var calendarStartDate: Date?
     var calendarEndDate: Date?
     var allDayEvent: Bool?
     var event = Event()
     let center = UNUserNotificationCenter.current()
     
     override func viewDidLoad() {
          super.viewDidLoad()
          
          if WCSession.isSupported() {
               session = WCSession.default()
               session?.delegate = self
               session?.activate()
          }
          
          tableView.reloadData()
     }
     
     override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(true)
          
          tableView.reloadData()
     }
     
     override func didReceiveMemoryWarning() {
          super.didReceiveMemoryWarning()
          // Dispose of any resources that can be recreated.
     }
     
     func sendApplicationContext() {
          if let validSession = session {
               let iPhoneAppContext = ["events": event.events, "date": event.date] as [String : Any]
               do {
                    try validSession.updateApplicationContext(iPhoneAppContext as [String : AnyObject])
               } catch {
                    print("Something went wrong")
               }
          }
     }
     
     // MARK: Table view data source
     
     override func numberOfSections(in tableView: UITableView) -> Int {
          
          if event.events.count > 0 {
               
               self.tableView.backgroundView = nil
               self.tableView.separatorStyle = UITableViewCellSeparatorStyle.singleLine
               
          } else {
               
               let noDataLabel: UILabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: self.tableView.bounds.size.height))
               noDataLabel.font = UIFont.systemFont(ofSize: 50)
               noDataLabel.text = "No Events"
               noDataLabel.textColor = UIColor.darkGray
               noDataLabel.textAlignment = NSTextAlignment.center
               self.tableView.backgroundView = noDataLabel
               self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
          }
          return 1
     }
     
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return event.events.count
     }
     
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
          
          let dateFormatter = DateFormatter()
          dateFormatter.dateStyle = .medium
          dateFormatter.timeStyle = .short
          let selectedDate = dateFormatter.string(from: event.date[(indexPath as NSIndexPath).row] as Date)
          let timeLeft = event.date[(indexPath as NSIndexPath).row].timeIntervalSinceNow
          
          if timeLeft <= 0 {
               cell.textLabel?.textColor = UIColor.red
               cell.detailTextLabel?.textColor = UIColor.red
          } else {
               cell.textLabel?.textColor = UIColor.black
               cell.detailTextLabel?.textColor = UIColor.black
          }
          
          cell.textLabel?.text = event.events[(indexPath as NSIndexPath).row]
          cell.detailTextLabel?.text = selectedDate
          
          return cell
     }
     
     override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
          event.userDefaults!.set((indexPath as NSIndexPath).row, forKey: "index")
     }
     
     
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
          // Return false if you do not want the specified item to be editable.
          return true
     }
     
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
               // Delete the row from the data source
               cancelLocalNotification(String(describing: event.date[(indexPath as NSIndexPath).row]))
               event.events.remove(at: (indexPath as NSIndexPath).row)
               event.date.remove(at: (indexPath as NSIndexPath).row)
               event.userDefaults!.set(event.events, forKey: "events")
               event.userDefaults!.set(event.date, forKey: "date")
               let index = event.userDefaults?.integer(forKey: "index")
               if index == (indexPath as NSIndexPath).row {
                    event.userDefaults?.set(0, forKey: "index")
               }
               
               tableView.deleteRows(at: [indexPath], with: .fade)
               sendApplicationContext()
          }
     }
     
     // MARK: Navigation
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
          if segue.identifier == "ShowDetail" {
               let selectedCell = sender as? UITableViewCell, selectedRowIndex = (tableView.indexPath(for: selectedCell!)! as NSIndexPath).row
               let eventName = event.events[selectedRowIndex]
               let eventDate = event.date[selectedRowIndex]
               let detailViewController = segue.destination as! ViewController
               detailViewController.eventTitle = eventName
               detailViewController.eventDate = eventDate
          }
     }
     
     @IBAction func cancelToEventsTableViewController(_ segue:UIStoryboardSegue) {
          
     }
     
     @IBAction func saveEvent(_ segue:UIStoryboardSegue) {
          if let addEventViewController = segue.source as? AddEventViewController {
               if let eventName = addEventViewController.eventTextField.text {
                    event.events.append(eventName)
                    calendarEvent = eventName
                    event.userDefaults?.set(event.events, forKey: "events")
               }
               
               if let eventDate = addEventViewController.startDate {
                    event.date.append(eventDate)
                    calendarStartDate = eventDate as Date
                    event.userDefaults?.set(event.date, forKey: "date")
                    self.localNotification(eventDate as Date)
               }
               
               if addEventViewController.addToCalendarSwitch.isOn {
                    if addEventViewController.allDayEventSwitch.isOn {
                         allDayEvent = true
                    } else {
                         allDayEvent = false
                    }
                    
                    if let eventEndDate = addEventViewController.endDate {
                         calendarEndDate = eventEndDate as Date
                    }
                    
                    if let alertTitle = addEventViewController.reminderDetailLabel.text {
                         
                         var dateOffset = TimeInterval()
                         
                         switch (alertTitle) {
                              
                         case "5 minutes":
                              dateOffset = (60 * 5)
                              
                         case "1 hour":
                              dateOffset = (60 * 60)
                              
                         case "1 day":
                              dateOffset = (TimeInterval(60 * 60 * 24))
                              
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
     
     func saveNewEvent(_ dateOffset: TimeInterval) {
          
          eventStore = EKEventStore()
          eventStore.requestAccess(to: EKEntityType.event) { (Granted, error) in
               
               if Granted {
                    let newEvent = EKEvent(eventStore: self.eventStore)
                    newEvent.title = self.calendarEvent!
                    newEvent.startDate = self.calendarStartDate!
                    newEvent.endDate = self.calendarEndDate!
                    newEvent.isAllDay = self.allDayEvent!
                    newEvent.calendar = self.eventStore.defaultCalendarForNewEvents
                    newEvent.addAlarm(EKAlarm(relativeOffset: -dateOffset))
                    
                    do {
                         try self.eventStore.save(newEvent, span: .thisEvent)
                    }catch{
                         let ac = UIAlertController(title: "Cannot create event", message: "The start date must be before the end date", preferredStyle: .alert)
                         ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                         self.present(ac, animated: true, completion: nil)
                    }
                    
               } else {
                    let ac = UIAlertController(title: "Need permission to access your calendar", message: "The app is not permitted to access your calendar, make sure to grant permission in the settings and try again", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "Settings", style: .default, handler: { action in
                         self.openSettings()
                    }))
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
               }
          }
     }
     
     func openSettings() {
          let url = URL(string: UIApplicationOpenSettingsURLString)
          UIApplication.shared.open(url!, options: [:], completionHandler: nil)
     }
     
     func localNotification(_ eventDate: Date) {
          
          center.getNotificationSettings { (settings) in
               if settings.authorizationStatus != .authorized {
                    let ac = UIAlertController(title: "Can't schedule", message: "Either we don't have permission to schedule notifications, or we haven't asked yet.", preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(ac, animated: true, completion: nil)
                    return
               }
          }
          
          
          let notification = UNMutableNotificationContent()
          let dict:NSDictionary = ["ID": String(describing: eventDate)]
          let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: eventDate)
          let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
          notification.userInfo = dict as! [String: AnyObject]
          notification.title = event.events.last!
          notification.body = "Dismiss"
          notification.sound = UNNotificationSound.default()
          let identifier = notification.userInfo["ID"] as! String
          let request = UNNotificationRequest(identifier: identifier, content: notification, trigger: trigger)
          center.add(request)
     }
     
     func cancelLocalNotification(_ uniqueID: String) {
          center.getPendingNotificationRequests(completionHandler: { requests in
               for request in requests {
                    if let info = request.content.userInfo as? [String: String] {
                         if info["ID"] == uniqueID {
                              self.center.removePendingNotificationRequests(withIdentifiers: [uniqueID])
                         }
                    }
               }
          })
          
     }
     
     // MARK: WCSessionDelegate
     
     func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
          if let error = error {
               print("session activation failed with error: \(error.localizedDescription)")
               return
          }
          
          print("session activated with state: \(activationState.rawValue)")
          sendApplicationContext()
     }
     
     func sessionDidBecomeInactive(_ session: WCSession) {
          /*
           The `sessionDidBecomeInactive(_:)` callback indicates sending has been disabled. If your iOS app
           sends content to its Watch extension it will need to stop trying at this point. This sample
           doesn’t send content to its Watch Extension so no action is required for this transition.
           */
          
          print("session did become inactive")
     }
     
     func sessionDidDeactivate(_ session: WCSession) {
          print("session did deactivate")
          
          /*
           The `sessionDidDeactivate(_:)` callback indicates `WCSession` is finished delivering content to
           the iOS app. iOS apps that process content delivered from their Watch Extension should finish
           processing that content and call `activateSession()`. This sample immediately calls
           `activateSession()` as the data provided by the Watch Extension is handled immediately.
           */
     }

     
     
}
