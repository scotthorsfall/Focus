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

    var tasks: [PFObject] = [PFObject]()
    
    var highlightColor: UIColor! = UIColor(red: 119/255, green: 125/255, blue: 136/255, alpha: 1)
    var labelColor: UIColor! = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.5)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
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
        
        // return whichever, will make tableview with 5 cells right now
        return tasks.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TaskCell")!

        let task = tasks[indexPath.row]
        cell.textLabel!.text = task["title"] as? String
        
        cell.textLabel!.textColor = highlightColor
        
        return cell
    }
    
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.row == 0 {
//            return 100
//        } else {
//            return 50
//        }
//    }
    
    func didAddTask(task: PFObject) {
        tasks.insert(task, atIndex: 0)
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        let vc = segue.destinationViewController as! CreateViewController
        
        vc.delegate = self
        
        
    }

    @IBAction func didCloseTask(sender: AnyObject) {
        
        //Dissmiss Create View and kill all edits
        self.dismissViewControllerAnimated(true, completion: nil)

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
