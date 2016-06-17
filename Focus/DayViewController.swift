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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
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
    

}
