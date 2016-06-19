//
//  DayViewController.swift
//  Focus
//
//  Created by Scott Horsfall on 6/16/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit

class DayViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var navItem: UINavigationItem!
    @IBOutlet weak var eventsTableView: UITableView!
    

    @IBOutlet weak var taskTrayView: UIView!
    
    //Var for tray
    var trayOriginalCenter: CGPoint!
    var trayDownOffset: CGFloat!
    var trayUp: CGPoint!
    var trayDown: CGPoint!
    var taskViewController: UIViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Add Task view controller to tasy tray view
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        taskViewController = storyboard.instantiateViewControllerWithIdentifier("TasksViewController")
        taskTrayView.addSubview(taskViewController.view)

        //Set Tray View Values
        trayDownOffset = 200
        trayUp = taskTrayView.center
        trayDown = CGPoint(x: taskTrayView.center.x, y: taskTrayView.center.y + trayDownOffset)
        
        //Set Tray closed on Load
        taskTrayView.center = trayDown

        
        
        eventsTableView.delegate = self
        eventsTableView.dataSource = self
        
        navItem.title = "Today"

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 5
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        // store variables for cell heights
        let taskCellHeight: CGFloat = 88.0
        let meetingCellHeight: CGFloat = 44.0
        
        // fake the cell heights
        if indexPath.row == 1 || indexPath.row == 3 {
            return taskCellHeight
        }
        return meetingCellHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        if indexPath.row == 1 || indexPath.row == 3 {
            cell = eventsTableView.dequeueReusableCellWithIdentifier("taskCell")!
            cell.textLabel!.text = "2 hours free"
        } else {
            // has meetings
            cell = eventsTableView.dequeueReusableCellWithIdentifier("meetingCell")!
            cell.textLabel!.text = "2 meetings at 1:00 PM"
        }
        
        return cell
        
    }
    
    @IBAction func didPanTray(sender: UIPanGestureRecognizer) {
        
        let translation = sender.translationInView(view)
        let velocity = sender.velocityInView(view)
        
        
        if sender.state == UIGestureRecognizerState.Began {
            
            trayOriginalCenter = taskTrayView.center
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            
            taskTrayView.center = CGPoint(x: trayOriginalCenter.x, y: trayOriginalCenter.y + translation.y)
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            
            if velocity.y > 0 {
                // move down
                
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1,  options: [], animations: {
                    () -> Void in self.taskTrayView.center = self.trayDown
                    }, completion: { (Bool) -> Void in
                })
                
            } else {
                // move up
                UIView.animateWithDuration(0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1,  options: [], animations: {
                    () -> Void in self.taskTrayView.center = self.trayUp
                    }, completion: { (Bool) -> Void in
                })
            }
        }
    }

    

}
