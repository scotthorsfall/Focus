//
//  EditViewController.swift
//  Focus
//
//  Created by Scott Horsfall on 7/4/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit
import Parse

class EditViewController: UIViewController {
    
    // vars
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var saveView: UIView!
    @IBOutlet weak var saveButton: UIButton!
    
    // initial vars
    var initialSaveViewY: CGFloat!
    var initialFormViewY: CGFloat!
    var offset: CGFloat!
    
    // pass data
    var taskTitle: String!
    var taskTime: Int!

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
        
        // pass data
        titleTextField.text = taskTitle
        timeTextField.text = String(taskTime)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        // title activates keyboard
        titleTextField.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func didTapView(sender: UITapGestureRecognizer) {
        
        // tap on wash hides keyboard
        view.endEditing(true)
        
    }
    
    @IBAction func didEnterInput(sender: AnyObject) {
        if (titleTextField.text!.isEmpty || timeTextField.text!.isEmpty) {
            saveButton.enabled = false
        } else {
            saveButton.enabled = true
        }
    }
    
    func keyboardWillShow(notification: NSNotification!) {
        print("show keyboard")
        
        let frame = notification.userInfo![UIKeyboardFrameEndUserInfoKey]!.CGRectValue()
        
        formView.frame.origin.y = initialFormViewY + offset
        
        // move save up w/ keyboard height
        saveView.frame.origin.y = initialSaveViewY - frame.height
        
        
    }
    
    func keyboardWillHide(notification: NSNotification!) {
        print("hide keyboard")
        
        formView.frame.origin.y = initialFormViewY
        saveView.frame.origin.y = initialSaveViewY
        
    }
    
    @IBAction func didTapClose(sender: UIButton) {
        
        // alert if fields were changed
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    @IBAction func didTapSave(sender: UIButton) {
        
        // save the fields
        
        let tasksVC = UIViewController() as! TasksViewController
        print("tasks VC: \(tasksVC)")
        
        self.navigationController?.popViewControllerAnimated(true)

    }
    
}
