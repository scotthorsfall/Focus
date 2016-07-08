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
    
    var insertMode: Bool! = false
    var insertTaskMode: Bool! = false
    
    var selectedMeetingIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(animated: Bool) {
        insertTaskMode = insertMode
        fetchTasksAndUpdateLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchTasksAndUpdateLabel() {
      
        let query = PFQuery(className: "Task")
        query.whereKey("user", equalTo: PFUser.currentUser()!)
        
        query.findObjectsInBackgroundWithBlock { (tasks: [PFObject]?, error: NSError?) in
            self.tasks = tasks!
            self.tableView.reloadData()
            
            self.updateTaskDrawerLabel()
        }
        
    }
    
    func updateTaskDrawerLabel() {
        // update task drawer label
        let taskCount = self.tasks.count
        if taskCount > 1 {
            self.navLabel.text = "\(taskCount) Tasks"
        } else {
            self.navLabel.text = "\(taskCount) Tasks"
        }
        
        print(self.navLabel.text)
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
        let task = tasks[indexPath.row]
        
        if editingStyle == .Delete {
            
            /********************************************
            
             
            TODO: Jonathan, we need to remove the taskObject from the task list here
 
             
            *********************************************/
            let query = PFQuery(className: "Task");
            query.whereKey("objectId", equalTo: task.objectId!)
            query.findObjectsInBackgroundWithBlock { (tasksToDelete: [PFObject]?, error: NSError?) in
                
                for task in tasksToDelete! {
                    print("deleting task: \(task["title"])")
                    task.deleteEventually()
                }
            }

            tasks.removeAtIndex(indexPath.row)
            print("tasks left: \(tasks.count)")
            updateTaskDrawerLabel()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
            print("removed task cell")
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
            
        }
    }
    
    func didAddTask(task: PFObject) {
        tasks.insert(task, atIndex: 0)
        updateTaskDrawerLabel()
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selectedTask = tasks[indexPath.row]
        print("selectedTask \(selectedTask["title"])")
        
        if insertTaskMode == true {
        
            insertTask()
        
        } else {
            
            self.performSegueWithIdentifier("taskDetailSegue", sender: self)
            
        }
        
    }
    
    func insertTask() {
        print("insert task")
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let dayVC = storyboard.instantiateViewControllerWithIdentifier("DayViewController") as! DayViewController
        
        print("insertVC: selectedMeetingIndex: \(selectedMeetingIndex)")
        
        dayVC.insertTask(selectedTask, index: selectedMeetingIndex)
        
        self.dismissViewControllerAnimated(true, completion: nil)
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
        tableView.reloadData()
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    @IBAction func didTapAdd(sender: AnyObject) {
        
        print("Tapped didTapAdd")
        
        performSegueWithIdentifier("createTaskSegue", sender: self)
        
    }
    
    func taskCellTapped(sender: AnyObject) {
        print("task cell tapped")
    }
    

}
