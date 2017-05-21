//
//  SingleChatViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 20/03/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//


import UIKit
import Firebase

class SingleChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var timer = Timer()
    var userName:String?
    var userId:String?
    var messageDictionary = [[String:String]]()
    
    
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        
        usernameLabel.text = userName
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        messageTextfield.delegate = self
        messageTextfield.isUserInteractionEnabled = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let UItap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(UItap)
        
        loadMessage()
        self.loadOneM()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissKeyboard() {
        //view.endEditing(true)
        messageTextfield.resignFirstResponder()
    }
    
    
    @IBAction func goBack() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: ChatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        self.messageDictionary.removeAll()
        
        self.present(view, animated: true, completion: nil)
        //self.timer.invalidate()
        
    }
    
    @IBAction func sendMessage() {
        let senderId = FIRAuth.auth()?.currentUser?.uid
        let receiverId = userId
        let message = self.messageTextfield.text
        let messageId1 = ("\(senderId!+receiverId!)")
        let messageId2 = ("\(receiverId!+senderId!)")
        let monitorData = [senderId!: "true"]
        let userRef = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("users").child(senderId!)
        
        userRef.observe(.value, with: { snapshot in 
            if let snap = snapshot.value as? [String:Any]{
                let username = snap["userName"]! as! String
                let messageData = ["messageId": messageId1, "userName":username, "message": message!, "userId":self.currentUser!]
                
                self.ref.child("messages").child(messageId1).childByAutoId().setValue(messageData)
                self.ref.child("messages").child(messageId2).childByAutoId().setValue(messageData)
                // LOAD SINGLE MESSAGE 
                //self.loadSingleMessage()
                
            }
        })
        messageTextfield.text = ""
        ref.child("monitorChanges").child("messages").child(receiverId!).updateChildValues(monitorData)
        
    }
    

    // FUNCTION TO LOAD ALL MESSAGES 
    func loadMessage(){
        let senderId = FIRAuth.auth()?.currentUser?.uid
        let receiverId = userId
        let messageId = ("\(senderId!+receiverId!)")
        let messageId2 = ("\(receiverId!+senderId!)")
        let userRef = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("users").child(senderId!)
        
        //let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("messages").queryOrdered(byChild: "messageId").queryEqual(toValue: messageId)
        
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("messages").child(messageId)
        
        
        
        // MESSAGE ID 1
        ref.observeSingleEvent(of: .value, with: { snapshot in
            // remove all 
            self.messageDictionary.removeAll()
            
            for snap in snapshot.children {
                let message = snap as! FIRDataSnapshot
                if let snap = snapshot.value as? [String:Any]{
                    if let messageValue = message.value as? [String: String] {
                        let message = messageValue["message"]!
                        let messageId = messageValue["messageId"]!
                        let user = messageValue["userName"]!
                        let userId = messageValue["userId"]!
                        
                        let messageArray = ["message" : message,
                                            "messageId": messageId,
                                            "userName": user,
                                            "userId" : userId
                        ]
                        
                        self.messageDictionary.append(messageArray)
                        self.tableView.reloadData()
                        self.setMessageIndexToBottom()
                        
                        print("---------------------------------------------------------------")
                        print("TEST DICT \(self.messageDictionary)")
                        print("---------------------------------------------------------------")
                    }
                }
            }
        })
    }
    
    func setMessageIndexToBottom(){
        let indexPath = IndexPath(row: self.messageDictionary.count-1, section: 0) 
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    
    func loadOneM(){
        let senderId = FIRAuth.auth()?.currentUser?.uid
        let receiverId = userId
        let messageId = ("\(senderId!+receiverId!)")

        
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("messages").child(messageId).queryLimited(toLast: 1).observe(.childAdded, with: { snapshot in 
            
            if let message = snapshot.value as? [String: Any]{
                let textMessage = message["message"]! as! String
                let textMessageUser = message["userName"]! as! String
                let userId = message["userId"]! as! String
                
                let messageArray = ["message" : textMessage,
                                    "messageId": messageId,
                                    "userName": textMessageUser,
                                    "userId" : userId
                ]
                
                self.messageDictionary.append(messageArray)
                self.tableView.reloadData()
                
                self.setMessageIndexToBottom()
                
                print("MY LAST M ::: \(textMessage)")
                
                
            }
            
        
        })
        
    }
    
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let uId = self.messageDictionary[indexPath.row]["userId"]
        var totalRow = tableView.numberOfRows(inSection: indexPath.section)
        

        
        if  uId == currentUser {
            //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            let cell = Bundle.main.loadNibNamed("EventMessageCell", owner: self, options: nil)?.first as! EventMessageCell
            
            cell.messageLabel.textAlignment = .right
            cell.usernameLabel.textAlignment = .right
            cell.messageLabel.layer.masksToBounds = true
            cell.messageLabel.layer.cornerRadius = 5
            
            
            cell.messageLabel.text = self.messageDictionary[indexPath.row]["message"]
            cell.usernameLabel.text = self.messageDictionary[indexPath.row]["userName"]
            
            return cell
        } else {
            let cell = Bundle.main.loadNibNamed("EventMessageCell", owner: self, options: nil)?.first as! EventMessageCell
            
            cell.messageLabel.textAlignment = .left
            cell.usernameLabel.textAlignment = .left
            cell.messageLabel.layer.masksToBounds = true
            cell.messageLabel.layer.cornerRadius = 5
            
            
            cell.messageLabel.text = self.messageDictionary[indexPath.row]["message"]
            cell.usernameLabel.text = self.messageDictionary[indexPath.row]["userName"]
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageDictionary.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    
    
    
    
    func keyboardWillShow(notification: NSNotification) {        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y -= keyboardHeight
        }  
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            self.view.frame.origin.y += keyboardHeight
        }  
    }
    
    
    
    
    
    
}
