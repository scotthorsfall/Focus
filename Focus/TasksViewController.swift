//
//  TasksViewController.swift
//  Focus
//
//  Created by Scott Horsfall on 6/16/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit
import Parse

class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CreateViewControllerDelegate  {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var navLabel: UILabel!
    
    var tasks: [PFObject] = [PFObject]()
    var selectedTask: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let taskCount = tasks.count
        var taskString = "Tasks"
        
        if taskCount == 1 {
            taskString = "Task"
        }
        
        navLabel.text = "\(taskCount) \(taskString)"

    }
    
    override func viewWillAppear(animated: Bool) {
        let query = PFQuery(className: "Task")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        
        // fetch from local storage which doesn't work right now
        // query.fromLocalDatastore()
        query.findObjectsInBackgroundWithBlock { (tasks: [PFObject]?, error: NSError?) in
            self.tasks = tasks!
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("tasks count \(tasks.count)")
        
        // return as many cells as objects in tasks array
        return tasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell") as! TaskListTableViewCell

        let task = tasks[indexPath.row]
        let taskTitle = String(task["title"])
        let taskDuration = task["time"] as! Int
        var hourString = "HOUR"
        
        if taskDuration > 1 {
            hourString = "HOURS"
        }
        
        cell.titleLabel.text = taskTitle
        cell.durationLabel.text = String("\(taskDuration) \(hourString)")
        
        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // the cells you would like the actions to appear needs to be editable
        return true
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        //let taskObject = PFObject(className: "Task")
        
        if editingStyle == .Delete {
            
            /********************************************
            
             
            TODO: Jonathan, we need to remove the taskObject from the task list here
 
             
            *********************************************/
            
            tasks.removeAtIndex(indexPath.row)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            print("removed task cell")
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }
    
    func didAddTask(task: PFObject) {
        tasks.insert(task, atIndex: 0)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        selectedTask = tasks[indexPath.row]
        print("selectedTask \(selectedTask))")
        
        self.performSegueWithIdentifier("taskDetailSegue", sender: self)
        
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "taskDetailSegue" {
            print("segue to task detail")
            
            let editVC = segue.destinationViewController as! EditViewController
          
            editVC.taskTitle = String(selectedTask["title"])
            editVC.taskTime = selectedTask["time"] as! Int
        }
        
    }

    @IBAction func didCloseTask(sender: AnyObject) {
        
        //Dissmiss Create View and kill all edits
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func didTapAdd(sender: AnyObject) {
        
        print("Tapped didTapAdd")
        
        performSegueWithIdentifier("createTaskSegue", sender: self)
        
    }
    
    func taskCellTapped(sender: AnyObject) {
        print("task cell tapped")
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    

}
