//
//  DayViewController.swift
//  Focus
//
//  Created by Scott Horsfall on 6/16/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit
import EventKit

class DayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // navigation vars
    @IBOutlet weak var navItem: UINavigationItem!
    
    
    // mainview vars
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var taskTrayView: UIView!
    
    @IBOutlet weak var taskButton: UIButton!
    @IBOutlet weak var createTaskButton: UIButton!
    
    var highlightColor: UIColor! = UIColor(red: 119/255, green: 125/255, blue: 136/255, alpha: 1)
    var labelColor: UIColor! = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
    
    // CALENDAR / tableView variables
    // store the events from calendar
    var eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var eventsInDayRange: [EKEvent]?
    var meetingsInDay: [EKEvent]! = []
    
    // store our events here
    var focusEventStore: [EKEvent]! = []
    
    // set current day (0 = today)
    // TODO: update this as views change
    var currentDay: Int! = 0
    
    // set work day beginning and end hours
    // TODO: get these from somewhere
    var dayStartTime: Int! = 9
    var dayEndTime: Int! = 17
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        
        navItem.title = "Today"
        
        // check calendar status on appear
        checkCalendarAuthorizationStatus()
        
        // Setting Task button to show number of tasks
//        let taskViewController = UIViewController() as! TasksViewController
//        
//        let totalTasks = taskViewController.tasks.count
//        
       
        taskButton.setTitle("Tasks", forState: .Normal)
        


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
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
            
            // TODO need to a state for if we didn't get access
        }
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccessToEntityType(EKEntityType.Event, completion: {
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
        
        /*
         STEP 1
         Get list of all events in range today
         */
        
        // get calendars
        calendars = eventStore.calendarsForEntityType(EKEntityType.Event)
        
        // set beginning and end of day (based on currentDay var)
        // use now.dayBegin()! to reset to 12:00am of that day
        // TODO: change these to actual dates and be able to modify them (global vars) in next/previous
        let beginningDate = NSDate(timeInterval: Double(currentDay)*24*60*60, sinceDate: NSDate().dayBegin()!)
        let endDate = NSDate(timeInterval: 1*24*60*60, sinceDate: beginningDate)
        
        navItem.title = dateFormatterToString(beginningDate, dateStyle: "Short")
        
        // get all events within range on calendar
        let predicate = eventStore.predicateForEventsWithStartDate(beginningDate, endDate: endDate, calendars: calendars)
        self.eventsInDayRange = eventStore.eventsMatchingPredicate(predicate)
        
        /*
         STEP 2
         Copy result into something we can modify, if needed
         */
        
        var eventsCopy = eventsInDayRange
        
        /*
         STEP 3
         The main logic block
         
         Group events from eventsCopy to meeting blocks in meetingsInDay
         */
        
        // if eventsCopy has events
        if eventsCopy!.count > 0 {
            
            // setup variable for the main while loop
            var mainIndexStore = 0
            
            // store how many events were merged
            var mergedEvents = 1
            
            // while the index < the # of events in eventsCopy
            while mainIndexStore < eventsCopy!.count {
                
                // if event is all day, remove it
                if eventsCopy![mainIndexStore].allDay {
                    eventsCopy!.removeAtIndex(mainIndexStore)
                }
                
                // get the event at the current index in eventsInRange
                let currentEvent = eventsCopy![mainIndexStore]
                
                // setup the current and next events vars to store
                var nextEvent: EKEvent! = EKEvent(eventStore: eventStore)
                
                // check if the next event is valid, if not = end of array
                if (mainIndexStore + 1) < eventsCopy?.count {
                    
                    // set the next event when (index + 1) is valid
                    nextEvent = eventsCopy![mainIndexStore + 1]
                    
                    if currentEvent.endDate.isEqualToDate(nextEvent.startDate) {
                        // CATCH adjacent meetings
                        
                        // set current event end time to equal next event end time
                        currentEvent.endDate = nextEvent.endDate
                        
                        // delete the nextEvent
                        eventsCopy!.removeAtIndex(mainIndexStore+1)
                        mergedEvents += 1
                        
                        // dont increment the while
                        mainIndexStore += 0
                        
                    } else if currentEvent.endDate.isGreaterThanDate(nextEvent.startDate) {
                        // CATCH overlapping meetings
                        
                        if currentEvent.endDate.isGreaterThanDate(nextEvent.endDate) || currentEvent.endDate.isEqualToDate(nextEvent.endDate) {
                            
                            // delete the nextEvent
                            eventsCopy!.removeAtIndex(mainIndexStore+1)
                            mergedEvents += 1
                            
                            // dont increment the while loop
                            
                        } else {
                            
                            // set current events end time = next event end time
                            currentEvent.endDate = nextEvent.endDate
                            // delete the next event
                            
                            // delete the nextEvent
                            eventsCopy!.removeAtIndex(mainIndexStore+1)
                            mergedEvents += 1
                            
                            // dont increment the while
                            
                        }
                        
                    } else {
                        // CATCH nothing is overlapping or adjacent, anymore
                        
                        // add currentEvent to meetings in day
                        if mergedEvents >= 2 {
                            currentEvent.title = "\(mergedEvents) meetings"
                        } else {
                            currentEvent.title = "Meeting"
                        }
                        
                        meetingsInDay.append(currentEvent)
                        
                        // increase while
                        mainIndexStore += 1
                        mergedEvents = 1
                    }
                    
                } else {
                    
                    // CATCH last event happening, should only happen if no adjacent events before
                    
                    //print("adding MEETING \(currentEvent.title) @ \(currentEvent.startDate.hour()!) - \(currentEvent.endDate.hour()!) to meetingsInDay ")
                    // add currentEvent to meetings in day
                    currentEvent.title = "Meeting"
                    meetingsInDay.append(currentEvent)
                    
                    // increase while
                    mainIndexStore += 1
                    
                }
            }
            
        } else {
            // CATCH no events today
            //print("no events found today")
            
        }
        
        /*
         STEP 5
         Find free blocks on the calendar
         
         */
        
        // setup when the day should start and when it should end (within work hours)
        // TODO: might have to convert these to allow the currentDay variable
        let dayStart: NSDate! = beginningDate.setHour(dayStartTime)
        let dayEnd: NSDate! = beginningDate.setHour(dayEndTime)
        
        // create an event for when the day starts
        let dayStartEvent: EKEvent! = EKEvent(eventStore: eventStore)
        dayStartEvent.startDate = dayStart
        dayStartEvent.title = "FREE"
        
        var startEventAdded = false
        
        // create and event for when the day ends
        let dayEndEvent: EKEvent! = EKEvent(eventStore: eventStore)
        dayEndEvent.startDate = dayEnd
        dayEndEvent.endDate = dayEnd
        dayEndEvent.title = "FREE"
        
        if meetingsInDay.count > 0 {
            
            // store the when the freeEvent should start
            var freeEventStart = NSDate()
            
            // day has meetings
            for meeting in meetingsInDay {
                
                // create a generic free event
                let freeEvent: EKEvent! = EKEvent(eventStore: eventStore)
                freeEvent.title = "FREE"
                freeEvent.startDate = freeEventStart
                
                // CHECK when the first free block is
                if meeting.startDate.isLessThanDate(dayStartEvent.startDate) || meeting.startDate.isEqualToDate(dayStartEvent.startDate) {
                    
                    // starts before or when the day should start
                    
                    dayStartEvent.startDate = meeting.endDate
                    
                    // add meeting to focus events
                    focusEventStore.append(meeting)
                    
                } else {
                    
                    if !startEventAdded {
                        // add free block from start of day ->  first meeting time
                        dayStartEvent.endDate = meeting.startDate
                        
                        // add dayStartEvent
                        focusEventStore.append(dayStartEvent)
                        // add meeting
                        focusEventStore.append(meeting)
                        
                        startEventAdded = true
                        
                    } else {
                        
                        freeEvent.endDate = meeting.startDate
                        
                        // add free event and meeting event
                        focusEventStore.append(freeEvent)
                        focusEventStore.append(meeting)
                        
                    }
                    
                    // reset the free event start time
                    freeEventStart = meeting.endDate
                }
            }
            
            if meetingsInDay.last!.endDate.isLessThanDate(dayEndEvent.startDate) {
                
                dayEndEvent.startDate = meetingsInDay.last!.endDate
                
                focusEventStore.append(dayEndEvent)
                
            }
            
        } else {
            
            // day has no meetings
            dayStartEvent.endDate = dayEndEvent.startDate
            focusEventStore.append(dayStartEvent)
            
        }
        
        
        /* MEETING CHECK
        for meeting in focusEventStore {
            let start = timeFormatterToString(meeting.startDate, timeStyle: "Short")
            let end = timeFormatterToString(meeting.endDate, timeStyle: "Short")
            
            print("\(meeting.title): \(start) - \(end) ")
        }
        */
        
    }
    
    func refreshTableView() {
        eventsTableView.reloadData()
    }
    
    // set number of cells
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // show this many events
        return focusEventStore.count
        
    }
    
    // set height
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // Get duration of free blocks
        //let event = focusEventStore[indexPath.row]
        //let duration = event.endDate.hoursFrom(event.startDate)
        
        // setup cell heights
        let freeCellHeight: CGFloat = 128.0
        let meetingCellHeight: CGFloat = 44.0
        
        if focusEventStore[indexPath.row].title == "FREE" {
            
            
            /* Attemting to have mixed heights
             
            set free cell height based on block length X base
            freeCellHeight = freeCellHeight * CGFloat(duration)
            
            
            Attempting to center labels in cell
            
            let cell = tableView.dequeueReusableCellWithIdentifier("freeCell") as! FreeTableViewCell
            let centerLabel = cell.freeCellParentView.center.y

            cell.labelContainerView.center.y = centerLabel
 
 
            print("\(centerLabel)")
            print("\(cell.labelContainerView.center.y)")
            */
            
            return freeCellHeight
        }
        
        return meetingCellHeight
        
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        
        let event = focusEventStore[indexPath.row]
        
        let startTime = timeFormatterToString(event.startDate, timeStyle: "Short")
        //let endTime = timeFormatterToString(event.endDate, timeStyle: "Short")
        
        if focusEventStore[indexPath.row].title == "FREE" {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("freeCell") as! FreeTableViewCell
            
            let timeText = event.endDate.stringTimeFromFloat(event.startDate)
            let hours = event.endDate.timeFromFloat(event.startDate)
            
            cell.timeLabel.text = startTime
            
            let durationString = "\(hours) \(timeText) FREE"
            
            cell.durationLabel.text = durationString.uppercaseString
            
            return cell
            
            
        } else {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("meetingCell") as! MeetingTableViewCell
            
            cell.meetingLabel.text = "\(event.title) at \(startTime)"
            cell.userInteractionEnabled = false
            
            return cell
        }
    }

    @IBAction func onNextDayTap(sender: AnyObject) {
        print("next day")
        
        // reset tableView store
        focusEventStore = []
        eventsTableView.hidden = true
        refreshTableView()
        
        print("focuseventstore count \(focusEventStore.count)")
        
        // increment day
        currentDay = currentDay + 1
        print("current day: \(currentDay)")
        
        // reload data
        self.loadEvents()
        self.refreshTableView()
        eventsTableView.hidden = false
        
    }
    
    @IBAction func onPreviousDayTap(sender: AnyObject) {
        print("previous day")
        
        // reset tableView store
        focusEventStore = []
        eventsTableView.hidden = true
        refreshTableView()
        
        // increment day
        currentDay = currentDay - 1
        
        // reload data
        self.loadEvents()
        self.refreshTableView()
        eventsTableView.hidden = false
        
    }
    
}
