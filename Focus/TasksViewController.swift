//
//  TasksViewController.swift
//  Focus
//
//  Created by Scott Horsfall on 6/16/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit

<<<<<<< Updated upstream
class TasksViewController: UIViewController, UITableViewDataSource, UITableViewDelegate  {
    
    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
    }
=======
class TasksViewController: UIViewController {
    @IBOutlet weak var taskTabelView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
   }
>>>>>>> Stashed changes

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
<<<<<<< Updated upstream
        // return whichever, will make tableview with 5 cells right now
=======
>>>>>>> Stashed changes
        return 5
        
    }
    
<<<<<<< Updated upstream
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell()
        
        cell.textLabel!.text = "2 hours free"
        
        return cell
        
    }
    
=======
>>>>>>> Stashed changes

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
