//
//  ScottDayViewController.swift
//  Focus
//
//  Created by Scott Horsfall on 6/14/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit
import EventKit

class ScottDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var hoursOfWorkday: [Int!] = [9,10,11,12,13,14,15,16,17]

    let freeCellHeight: CGFloat = 88.0
    let meetingCellHeight: CGFloat = 44.0
    
    var startTimes: [NSDate] = []
    var endTimes: [NSDate] = []
    
    @IBOutlet weak var viewTitle: UILabel!
    
    // eventsList
    var eventStoreLocal = EKEventStore()
    var calendars: [EKCalendar]?
    var eventsInRange: [EKEvent]?
    
    // store dates in here
    var focusEventStore = EKEventStore()
    
    // create a copy of the events 
    var copyEvents: [EKEvent]?
    var finalEvents: [EKEvent] = []
    
    // store final events in focusEvents
    var focusEvents: [EKEvent] = []
    var focusEventDates: [NSDate] = []
    
    // use variable for loadEvents while loop
    var indexStore = 0
    
    // use to check if event is a meeting or a free block
    var isMeetings: [Bool] = []
    
    var currentDay: Double! = 0
    
    @IBOutlet var eventsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        eventsTableView.hidden = true
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        checkCalendarAuthorizationStatus()
    }
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatusForEntityType(EKEntityType.Event)
        
        switch (status) {
        case EKAuthorizationStatus.NotDetermined:
            // first-run, get cal access
            requestAccessToCalendar()
        case EKAuthorizationStatus.Authorized:
            // success, got calendar access
            loadEvents()
            refreshTableView()
        case EKAuthorizationStatus.Restricted, EKAuthorizationStatus.Denied:
            // failed, didn't get access
            print("need permission")
        }
    }
    
    func requestAccessToCalendar() {
        eventStoreLocal.requestAccessToEntityType(EKEntityType.Event, completion: {
            (accessGranted: Bool, error: NSError?) in
            
            if accessGranted == true {
                dispatch_async(dispatch_get_main_queue(), {
                    self.loadEvents()
                    self.refreshTableView()
                })
            } else {
                dispatch_async(dispatch_get_main_queue(), {
                    //need permission
                })
            }
        })
    }
    
    func loadEvents() {
        // get calendars
        calendars = eventStoreLocal.calendarsForEntityType(EKEntityType.Event)
        
        // set beginning and end of day (based on currentDay var)
        // use now.dayBegin()! to reset to 12:00am of that day
        let beginningDate = NSDate(timeInterval: currentDay*24*60*60, sinceDate: NSDate().dayBegin()!)
        let endDate = NSDate(timeInterval: 1*24*60*60, sinceDate: beginningDate)
        
        // get all events within range on calendar
        let predicate = eventStoreLocal.predicateForEventsWithStartDate(beginningDate, endDate: endDate, calendars: calendars)
        self.eventsInRange = eventStoreLocal.eventsMatchingPredicate(predicate)
        
        //copy the eventsInRange to modify it
        copyEvents = eventsInRange
        
        // setup when the day should start and when it should end (within work hours)
        let dayStart: NSDate! = NSDate().setHour(9) // TODO using 9am temporarily
        let dayEnd: NSDate! = NSDate().setHour(17) // TODO using 5pm
        
        // create an event for when the day starts
        let dayStartEvent: EKEvent! = EKEvent(eventStore: focusEventStore)
        dayStartEvent.startDate = dayStart
        dayStartEvent.title = "FREE"
        
        // create and event for when the day ends
        let dayEndEvent: EKEvent! = EKEvent(eventStore: focusEventStore)
        dayEndEvent.startDate = dayEnd
        dayEndEvent.endDate = dayEnd
        dayEndEvent.title = "FREE"
        
        if copyEvents?.count > 0 {
            
            print("copyEvents has events")
            
            // if copyEvents has events
            while indexStore < copyEvents?.count {
                
                // get the event at the current index in eventsInRange
                let event = eventsInRange![indexStore]
                
                // setup the current and next events vars to store
                var currentEvent = event
                var nextEvent: EKEvent! = EKEvent(eventStore: focusEventStore)
                
                // create the event (meeting or free) that we want to add to focusEvents
                let addEvent: EKEvent! = EKEvent(eventStore: focusEventStore)
                
                // check if the next event is valid, if not = end of array
                if (indexStore + 1) < eventsInRange?.count {
                    
                    // set the next event when (index + 1) is valid
                    nextEvent = eventsInRange![indexStore+1]
                    
                    if nextEvent.startDate.isEqualToDate(currentEvent.endDate) || nextEvent.startDate.isLessThanDate(addEvent.endDate) {
                        
                        // nextEvent is = or < than currentEvent.endDate
                    
                    
                    } else {
                        
                        // if there's free time inbetween the current and the next event
                        
                        // add the current event to focusEvents to be a 'meeting' event
                        currentEvent.title = "MEETING"
                        focusEvents.append(currentEvent)
                        
                        // add an event after to be a 'free' event
                        addEvent.title = "FREE"
                        addEvent.startDate = currentEvent.endDate
                        addEvent.endDate = nextEvent.startDate
                        
                        // add to the array
                        focusEvents.append(addEvent)
                        
                    }
                    
                    
                    
                } else {
                    // hit the end of the array
                    
                    // add the current event to the array
                    currentEvent.title = "MEETING"
                    focusEvents.append(currentEvent)
                    
                    // use the dayEndEvent for end time
                    nextEvent = dayEndEvent
                    addEvent.title = "FREE"
                    addEvent.startDate = currentEvent.endDate
                    addEvent.endDate = nextEvent.startDate
                    
                    // add to the array
                    focusEvents.append(addEvent)
                }
            }
            
            
        } else {
            
            // if copyEvents has no events
            // entire day is free
            
            print("copyEvents has no events")
            
            let fullDayEvent: EKEvent! = EKEvent(eventStore: focusEventStore)
            fullDayEvent.startDate = dayStart
            fullDayEvent.endDate = dayEnd
            dayEndEvent.title = "FREE"
            
            finalEvents.append(fullDayEvent)
            
        }
        
    }
    
    func refreshTableView() {
        eventsTableView.hidden = false
        eventsTableView.reloadData()
        //print("table view refreshed")
    }
    
    func checkEventsOnCalendar(startTime: Int) -> Int {
        
        let beginDate = NSDate(timeInterval: (currentDay*24*60*60), sinceDate: NSDate().setHour(startTime)!)
        //print("beginTime: \(beginDate)")
        let endDate = NSDate(timeInterval: ((1*60*60)), sinceDate: beginDate)
        //print("endTime: \(endDate)")
  
        let predicate = eventStoreLocal.predicateForEventsWithStartDate(beginDate, endDate: endDate, calendars: calendars)
        let events = eventStoreLocal.eventsMatchingPredicate(predicate)
        
        //print("check events")
        
        /* eventStoreLocal.enumerateEventsMatchingPredicate(predicate) { event, stop in
            print("From \(beginDate.hour()!):\(beginDate.mins()!) to \(endDate.hour()!):\(endDate.mins()!), found: \(event.title) that starts at \(event.startDate.hour()!):\(event.startDate.mins()!) and ends at \(event.endDate.hour()!):\(event.endDate.mins()!)")
        }*/
        
        return events.count
        
    }
    
    
    // do the table view magic
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return focusEvents.count
        
    }
    
    // use this to set height of diff cells
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        //let eventCount = checkEventsOnCalendar(self.hoursOfWorkday[indexPath.row])
        
        if focusEvents[indexPath.row].title == "FREE" {
            return freeCellHeight
        }
        return meetingCellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        /*var amPM: String! = "AM"
        
        if indexPath.row > 2 {
            amPM = "PM"
        }
         */
        
        //let eventCount = checkEventsOnCalendar(self.hoursOfWorkday[indexPath.row])
        /*
        if eventCount > 0 {
            
            var meetingsString: String! = "meeting"
            
            if eventCount > 1 {
                meetingsString = "meetings"
            }
            
            // has meetings
            cell = tableView.dequeueReusableCellWithIdentifier("meetingCell")!
            cell.textLabel!.text = "\(eventCount) \(meetingsString) at \(hoursOfWorkday[indexPath.row]):00 \(amPM)"
        } else {
            // free block
            cell = tableView.dequeueReusableCellWithIdentifier("freeCell")!
            cell.textLabel!.text = "You're free at \(hoursOfWorkday[indexPath.row]):00 \(amPM)"
        }*/
        
        if focusEvents[indexPath.row].title == "FREE" {
            cell = tableView.dequeueReusableCellWithIdentifier("freeCell")!
            cell.textLabel!.text = "Free at \(focusEvents[indexPath.row].startDate.hourFormat()!)"
        } else {
            // has meetings
            cell = tableView.dequeueReusableCellWithIdentifier("meetingCell")!
            cell.textLabel!.text = "Meeting(s) from \(focusEvents[indexPath.row].startDate.hourFormat()!) - \(focusEvents[indexPath.row].endDate.hourFormat()!)"
            cell.userInteractionEnabled = false
        }

        return cell
    }
    
    /*
 
    GESTURE RECOGNIZERS
 
    */
    
    @IBAction func didPinchDay(sender: UIPinchGestureRecognizer) {
        
        print("did pinch")
    
    }
    
    @IBAction func didScreenPan(sender: UIPanGestureRecognizer) {
        //let point = sender.locationInView(view)
        //let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        if sender.state == UIGestureRecognizerState.Began {
            
            //
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            //
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            if velocity.y > 0 {
                print("pulled down -> settings")
            } else {
                print("pulled up -> tasks view")
            }
        }
        
    }
    

}

