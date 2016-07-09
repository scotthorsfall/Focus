//
//  DayViewController.swift
//  Focus
//
//  Created by Scott Horsfall on 6/16/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit
import EventKit
import Parse

class DayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // navigation vars
    //@IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var navTitle: UILabel!
    
    // mainview vars
    @IBOutlet weak var eventsTableView: UITableView!
    @IBOutlet var mainView: UIView!
    
    // testing subview
    @IBOutlet weak var newTaskTrayView: UIView!
    var tasksViewController: UIViewController!
    var fadeTransition: FadeTransition!
    
    // CALENDAR / tableView variables
    // store the events from calendar
    var eventStore = EKEventStore()
    var calendars: [EKCalendar]?
    var eventsInDayRange: [EKEvent]?
    var meetingsInDay: [EKEvent]! = []
    
    // store our events here
    var focusEventStore: [EKEvent]! = []
    var selectedMeeting: EKEvent!
    var selectedMeetingIndex: Int!
    var selectedMeetingNSIndexPath: NSIndexPath!
    
    // setup current day
    var today: NSDate! = NSDate().dayBegin()
    
    // set work day beginning and end hours
    // TODO: get these from somewhere
    var dayStartTime: Int! = 9
    var dayEndTime: Int! = 17
    
    // setup task to pass back
    var selectedTask: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        
        navTitle.text = today.titleFormat()
        
        // check calendar status on appear
        checkCalendarAuthorizationStatus()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        tasksViewController = storyboard.instantiateViewControllerWithIdentifier("TasksViewController") as! TasksViewController
        
        addChildViewController(tasksViewController)
        tasksViewController.view.frame = newTaskTrayView.bounds
        newTaskTrayView.addSubview(tasksViewController.view)
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
        
        navTitle.text = today.titleFormat()
        
        /*
         STEP 1
         Get list of all events in range today
         */
        
        // get calendars
        calendars = eventStore.calendarsForEntityType(EKEntityType.Event)
        
        // use NSDate.dayBegin()! to reset to 12:00am of that day
        let tomorrow = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: self.today, options: NSCalendarOptions(rawValue: 0))!
        
        let beginningDate = today
        let endDate = tomorrow
        
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
                
                // get the event at the current index in eventsInRange
                let currentEvent = eventsCopy![mainIndexStore]
                
                // setup the current and next events vars to store
                var nextEvent: EKEvent! = EKEvent(eventStore: eventStore)
                
                // if event is all day, remove it
                if currentEvent.allDay {
                    eventsCopy?.removeAtIndex(mainIndexStore)
                    mainIndexStore += 0
                } else if (mainIndexStore + 1) < eventsCopy?.count {
                    // check if the next event is valid, if not = end of array
                    
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
        
        
        /*
        //MEETING CHECK
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
        let taskCellHeight: CGFloat = 48.0
        
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
        } else if focusEventStore[indexPath.row].title == "Meeting" || focusEventStore[indexPath.row].title == "Meetings"  {
            
            return meetingCellHeight
            
        }
        
        return taskCellHeight
        
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
            
            
        } else if focusEventStore[indexPath.row].title == "Meeting" || focusEventStore[indexPath.row].title == "Meetings"  {
            
            let cell = tableView.dequeueReusableCellWithIdentifier("meetingCell") as! MeetingTableViewCell
            
            cell.meetingLabel.text = "\(event.title) at \(startTime)"
            cell.userInteractionEnabled = false
            
            return cell
        } else {
            // task cell
            
            let cell = tableView.dequeueReusableCellWithIdentifier("taskCell") as! TaskListTableViewCell
            
            let timeText = event.endDate.stringTimeFromFloat(event.startDate)
            let hours = event.endDate.timeFromFloat(event.startDate)
            
            let durationString = "\(hours) \(timeText)"

            
            cell.titleLabel.text = event.title
            cell.durationLabel.text = durationString.capitalizedString
            
            return cell
            
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // get the selected meeting
        selectedMeetingIndex = indexPath.row
        selectedMeetingNSIndexPath = indexPath
        selectedMeeting = focusEventStore[selectedMeetingIndex]
        
        if selectedMeeting.title == "FREE" {
            
            performSegueWithIdentifier("insertSegue", sender: self)

            eventsTableView.deselectRowAtIndexPath(indexPath, animated: true)
            
        }
        
    }
    
    func insertTask(task: PFObject!) {
        
        let taskTitle = task["title"] as! String
        let taskTime = task["time"] as! Int
        
        // set the end date of the task
        let taskEndDate = selectedMeeting.endDate.setHour(selectedMeeting.startDate.hour()! + taskTime)!
        
        // create the task event
        let taskMeeting: EKEvent! = EKEvent(eventStore: eventStore)
        taskMeeting.title = taskTitle
        taskMeeting.startDate = selectedMeeting.startDate
        taskMeeting.endDate = taskEndDate
        
        if taskMeeting.endDate.isLessThanDate(selectedMeeting.endDate) {
            // modify the selected free block
            focusEventStore[selectedMeetingIndex].startDate = taskMeeting.endDate
            eventsTableView.reloadRowsAtIndexPaths([selectedMeetingNSIndexPath], withRowAnimation: .None)
            // UPDATE THIS
        } else {
            // remove the selected free block
            focusEventStore.removeAtIndex(selectedMeetingIndex)
            eventsTableView.deleteRowsAtIndexPaths([selectedMeetingNSIndexPath], withRowAnimation: .None)
        }
        
        focusEventStore.insert(taskMeeting, atIndex: selectedMeetingIndex)
        eventsTableView.insertRowsAtIndexPaths([selectedMeetingNSIndexPath], withRowAnimation: .Top)
        
    }

    @IBAction func onNextDayTap(sender: AnyObject) {
        
        // reset tableView store
        focusEventStore = []
        meetingsInDay = []
        
        // increment day
        today = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: 1, toDate: today, options: NSCalendarOptions(rawValue: 0))!
        
        // reload data
        self.loadEvents()
        self.refreshTableView()
        
    }
    
    @IBAction func onPreviousDayTap(sender: AnyObject) {
        
        // reset tableView store
        focusEventStore = []
        meetingsInDay = []
        
        // subtract day
        today = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Day, value: -1, toDate: today, options: NSCalendarOptions(rawValue: 0))!
        
        // reload data
        self.loadEvents()
        self.refreshTableView()
        
    }
    
    @IBAction func onTasksTrayTap(sender: AnyObject) {
        
        performSegueWithIdentifier("toTasksViewSegue", sender: self)
        
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toTasksViewSegue" {
            print("to tasks segue")
            
            let destinationVC = segue.destinationViewController
            
            destinationVC.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
            
            fadeTransition = FadeTransition()
            
            destinationVC.transitioningDelegate = fadeTransition
            
            fadeTransition.duration = 0.5
            
        } else if segue.identifier == "insertSegue" {
            
            
            
            print("insert segue")
            
            let navVC = segue.destinationViewController as! UINavigationController
            let tasksVC = navVC.topViewController as! TasksViewController
            
            tasksVC.dayViewController = self
            tasksVC.insertMode = true
            tasksVC.selectedMeetingIndex = selectedMeetingIndex

            
        }
        
    }
}
