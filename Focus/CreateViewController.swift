//
//  CreateViewController.swift
//  Focus
//
//  Created by Jeremy Friedland on 6/21/16.
//  Copyright © 2016 Scott Horsfall. All rights reserved.
//

import UIKit

class CreateViewController: UIViewController {

    
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var saveView: UIView!
    
    var initialSaveViewY: CGFloat!
    var initialFormViewY: CGFloat!
    var offset: CGFloat!
    
    
    
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
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
