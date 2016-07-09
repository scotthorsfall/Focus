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
        
        print("present transition")
        
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
        
        print("navFrame: \(navBarItemsY)")
        
        tasksVC.view.frame = taskTrayFrame
        
        UIView.animateWithDuration(duration, animations: {
            
            // move it
            tasksVC.view.frame = taskViewFrame
            tasksVC.navBarItemsView.frame = navBarItemsFrame
            
        }) { (finished: Bool) -> Void in
            
            self.finish()
            
        }
    }
    
    override func dismissTransition(containerView: UIView, fromViewController: UIViewController, toViewController: UIViewController) {
        
        fromViewController.view.alpha = 1
        UIView.animateWithDuration(duration, animations: {
            fromViewController.view.alpha = 0
        }) { (finished: Bool) -> Void in
            self.finish()
        }
    }
}
