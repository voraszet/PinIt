//
//  ChatVC.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 01/05/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class ChatVC: UIViewController, UITextFieldDelegate {
    var messageId:String = ""
    var eventNameString:String = ""
    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    
    @IBOutlet weak var ChatTBVC: UIView!
    @IBOutlet weak var messageTextbox: UITextField!
    
    @IBOutlet weak var eventNameLabel: UILabel!
    
    @IBAction func sendMessages() {
        let message = self.messageTextbox.text
        self.ref.child("users").child(self.currentUser!).observe(.value, with: { snapshot in 
            let snap = snapshot as FIRDataSnapshot
            let timestamp = FIRServerValue.timestamp() 
            
            if let x = snap.value as? [String:Any]{
                let messageData = ["userName":x["userName"]!, "message": message!, "timestamp":timestamp, "userId":x["userId"]!]
                self.ref.child("event_messages").child(self.messageId).childByAutoId().setValue(messageData)
            }
        }) 
        
    }
    
    @IBAction func returnToPreviousView() {
        //let storyboard = UIStoryboard(name: "Main", bundle: nil)
        //let view: UserEventsController = storyboard.instantiateViewController(withIdentifier: "UserEventsController") as! UserEventsController
        
        self.dismiss(animated: true, completion: nil)
        //self.present(view, animated: true, completion: nil)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        eventNameLabel.text = eventNameString
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)    
        
        messageTextbox.delegate = self
        
        let UItap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(UItap)
        
    }
    
    func keyboardWillShow(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y -= keyboardHeight
        }
    }
    
    func keyboardWillHide(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y += keyboardHeight
        }   
    }

    
    func dismissKeyboard() {
        //view.endEditing(true)
        messageTextbox.resignFirstResponder()
    }
    
    var containerViewController: ChatTableView?
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ChatSegue" {
            let connectContainerViewController = segue.destination as! ChatTableView
            containerViewController = connectContainerViewController
            
            containerViewController?.messageId = messageId
            containerViewController?.eventNameString = eventNameString
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    

    

}
