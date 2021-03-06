//
//  CreateViewController.swift
//  Focus
//
//  Created by Jeremy Friedland on 6/21/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit
import Parse

@objc protocol CreateViewControllerDelegate {
    func didAddTask(task: PFObject)
}

class CreateViewController: UIViewController {

    
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    var initialSaveViewY: CGFloat!
    var initialFormViewY: CGFloat!
    var offset: CGFloat!
    var taskTitle: String!
    var taskTime: Int!
    
    weak var delegate: CreateViewControllerDelegate?
    
    override func viewWillAppear(animated: Bool) {
        
        //Title activates keyboard
        titleTextfield.becomeFirstResponder()
    }    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        //Register Keyboard Events
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow(_:)), name:UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide(_:)), name:UIKeyboardWillHideNotification, object: nil)
        
        
        //Set Variable Values
        initialFormViewY = formView.frame.origin.y
        initialSaveViewY = saveView.frame.origin.y
        
        //Need to set to keyboard height
        offset = -50

    }
    
    
    @IBAction func didTapView(sender: AnyObject) {
        
        //Tap on wash hides keyboard
        view.endEditing(true)
        
    }
    
    @IBAction func didEnterInput(sender: AnyObject) {
        if (titleTextfield.text!.isEmpty || timeTextField.text!.isEmpty) {
                saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
        
    }
    
    func keyboardWillShow(notification: NSNotification!) {
        print("show")
        
        let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        
        formView.frame.origin.y = initialFormViewY + offset
       
        // move save up w/ keyboard height
        saveView.frame.origin.y = initialSaveViewY - frame.height

        
    }
    
    func keyboardWillHide(notification: NSNotification!) {
        print("Hide")
        
        
        formView.frame.origin.y = initialFormViewY
        saveView.frame.origin.y = initialSaveViewY
        
        
    }
    
    @IBAction func didSaveTask(sender: AnyObject) {
        
        taskTitle = titleTextfield.text
        taskTime = Int(timeTextField.text!)
        
        let taskObject = PFObject(className: "Task")
        taskObject["title"] = taskTitle
        taskObject["time"] = taskTime
        taskObject["user"] = PFUser.currentUser()
        
        // save to cloud~~~
        taskObject.saveInBackgroundWithBlock {
            (succeeded: Bool, error: NSError?) -> Void in
            if error == nil {
                // Hooray! Let them use the app now.
                print("Task successfully created")
                self.delegate?.didAddTask(taskObject)
                
            } else {
                print("Error saving task...")
            }
            
        }
        
        // save to LocalStorage
        // taskObject.pinInBackground()
        
        //Dissmiss Create View and Save Task
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    @IBAction func didTapClose(sender: AnyObject) {
        
        //Dissmiss Create View and kill all edits
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }

}
