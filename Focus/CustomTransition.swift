//
//  CustomTransition.swift
//  Focus
//
//  Created by Scott Horsfall on 7/9/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//
import UIKit

class CustomTransition: BaseTransition {
    
    override func presentTransition(containerView: UIView, fromViewController: UIViewController, toViewController: UIViewController) {
        
        let dayVC = fromViewController as! DayViewController
        let navVC = toViewController as! UINavigationController
        let tasksVC = navVC.topViewController as! TasksViewController
        
        // frame stores
        let taskTrayFrame = dayVC.taskTrayView.frame
        let taskViewFrame = tasksVC.view.frame
        
        // task view nav
        var navBarItemsY = tasksVC.navBarItemsView.frame.minY
        navBarItemsY += 20.0
        let navBarItemsFrame = CGRect(x: tasksVC.navBarItemsView.frame.minX, y: navBarItemsY, width: tasksVC.navBarItemsView.frame.width, height: tasksVC.navBarItemsView.frame.height)
        
        // set the taskVC frame
        tasksVC.view.frame = taskTrayFrame
        
        UIView.animateWithDuration(duration, animations: {
            
            // fade out the dayVC
            dayVC.eventsTableView.alpha = 0
            dayVC.navView.alpha = 0
            
            // move it
            tasksVC.view.frame = taskViewFrame
            tasksVC.navBarItemsView.frame = navBarItemsFrame
            
            // - 7.5 is a temp hack, the centers are setting to be equal, off by 7.5
            tasksVC.navLabel.center.x = tasksVC.navBarItemsView.center.x
            
            // enable the close button
            tasksVC.navClose.enabled = true
            tasksVC.navClose.alpha = 1
            
        }) { (finished: Bool) -> Void in
            
            self.finish()
            
        }
    }
    
    override func dismissTransition(containerView: UIView, fromViewController: UIViewController, toViewController: UIViewController) {
        
        let navVC = fromViewController as! UINavigationController
        let tasksVC = navVC.topViewController as! TasksViewController
        let dayVC = toViewController as! DayViewController
        
        // frame stores
        let taskTrayFrame = dayVC.taskTrayView.frame
        let taskViewFrame = tasksVC.view.frame
        
        // task view nav
        var navBarItemsY = tasksVC.navBarItemsView.frame.minY
        navBarItemsY -= 20.0
        let navBarItemsFrame = CGRect(x: tasksVC.navBarItemsView.frame.minX, y: navBarItemsY, width: tasksVC.navBarItemsView.frame.width, height: tasksVC.navBarItemsView.frame.height)
        
        // set the taskVC frame
        tasksVC.view.frame = taskViewFrame
        
        // fade out the dayVC
        dayVC.eventsTableView.alpha = 0
        dayVC.navView.alpha = 0
        
        UIView.animateWithDuration(duration, animations: {
            
            // fade in the dayVC
            dayVC.eventsTableView.alpha = 1
            dayVC.navView.alpha = 1
            
            // move it
            tasksVC.view.frame = taskTrayFrame
            tasksVC.navBarItemsView.frame = navBarItemsFrame
            
            // move the label
            tasksVC.navLabel.frame = tasksVC.navLabelOriginalFrame
            
            // enable the close button
            tasksVC.navClose.alpha = 0
            
        }) { (finished: Bool) -> Void in
            
            tasksVC.navClose.enabled = false
            
            self.finish()
            
        }
        
    }
}
