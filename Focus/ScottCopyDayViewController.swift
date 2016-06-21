//
//  ScottCopyDayViewController.swift
//  Focus
//
//  Created by Scott Horsfall on 6/14/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit
import EventKit

class ScottCopyDayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var fakeEvents: Int! = 5
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
    
    
    // store dates in hurr
    var focusEventStore = EKEventStore()
    var focusEvents: [EKEvent] = []
    var rangeCopy: [EKEvent]?
    
    // create a copy of the events
    var copyEvents: [EKEvent]?
    var finalEvents: [EKEvent] = []
    
    var indexStore = 0
    
    var focusEventDates: [NSDate] = []
    
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
        calendars = eventStoreLocal.calendarsForEntityType(EKEntityType.Event)
        
        // set beginning and end
        // use now.dayBegin()! to reset to 12:00am of that day
        let beginningDate = NSDate(timeInterval: currentDay*24*60*60, sinceDate: NSDate().dayBegin()!)
        let endDate = NSDate(timeInterval: 1*24*60*60, sinceDate: beginningDate)
        
        // set the nav title with proper format
        viewTitle.text = beginningDate.titleFormat()
        
        // get all events within range on calendar
        let predicate = eventStoreLocal.predicateForEventsWithStartDate(beginningDate, endDate: endDate, calendars: calendars)
        self.eventsInRange = eventStoreLocal.eventsMatchingPredicate(predicate)
        
        //copy the eventsInRange to modify it
        rangeCopy = eventsInRange
        
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
        
        // TODO: make sure that eventsInRange! is not empty
        
        // initial free block check (if the dayStartEvent conflicts with first event in eventsInRange
        if dayStartEvent.startDate.isLessThanDate(eventsInRange![0].startDate) {
            print("first is less than")
        } else if dayStartEvent.startDate.isGreaterThanDate(eventsInRange![0].startDate) {
            print("first is greater than")
        } else if dayStartEvent.startDate.isEqualToDate(eventsInRange![0].startDate) {
            print("first is equal to")
        }
        
        if dayStartEvent.startDate.isGreaterThanDate(eventsInRange![0].startDate) || dayStartEvent.startDate.isEqualToDate(eventsInRange![0].startDate) {
            
            // do nothing, the dates conflict
            
        } else {
            // if the startDate doesn't conflict with the first event in eventsInRange
            // set the first block of free time, end date = start date of first meeting
            dayStartEvent.endDate = eventsInRange![0].startDate
            
            // append free block to focusEvent list
            focusEvents.append(dayStartEvent)
        }
        
        while indexStore < eventsInRange?.count {
            
            // get the event at the current index in eventsInRange
            let event = eventsInRange![indexStore]
            
            // setup the current and next events vars to store
            var currentEvent = event
            var nextEvent: EKEvent! = EKEvent(eventStore: focusEventStore)
            
            // define the event that we want to add to focusEvents
            let addEvent: EKEvent! = EKEvent(eventStore: focusEventStore)
            
            // check if the next event is valid, if not = end of array
            if (indexStore + 1) < eventsInRange?.count {
                
                // check until we hit the end of the array
                nextEvent = eventsInRange![indexStore+1]
                
                // TODO refactor this to use the copy array and hold everything there
                // or setup a temp event and dispose of it when out of the 'meetings' loop
                
                if nextEvent.startDate.isEqualToDate(currentEvent.endDate) || nextEvent.startDate.isLessThanDate(addEvent.endDate) {
                    
                    // make the currentevent end date = next event end date
                    
                    if currentEvent.endDate.isLessThanDate(nextEvent.endDate) {
                        currentEvent.endDate = nextEvent.endDate
                    } else {
                        nextEvent.endDate = currentEvent.endDate
                    }
                    
                    // if the events overlap OR but ends
                    addEvent.title = "MEETINGS"
                    addEvent.startDate = currentEvent.startDate
                    addEvent.endDate = currentEvent.endDate
                    
                    // add this to the copy array, probably a cleaner way to do this
                    rangeCopy![indexStore+1] = addEvent
                    
                    // dont add anything to the view, let the function run again
                    
                } else {
                    // if there's free time inbetween the current and the next event
                    
                    // check if the copied range was previously edited from above
                    if rangeCopy![indexStore].title == "MEETINGS" {
                        currentEvent = rangeCopy![indexStore]
                        
                        
                        
                    } else {
                        currentEvent.title = "MEETING"
                    }
                    
                    focusEvents.append(currentEvent)
                    
                    // set the added event to be free
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
            
            // increment the while loop
            indexStore += 1
        }
        
        // end while loop
        
        print("Focus Events Count: \(focusEvents.count)")
        
        for event in focusEvents {
            
            print("\(event.title), \(event.startDate.hourFormat()!) - \(event.endDate.hourFormat()!)")
        }
    }
    // end loadEvents
    
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

