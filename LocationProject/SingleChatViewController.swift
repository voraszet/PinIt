//
//  SingleChatViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 20/03/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//


import UIKit
import Firebase

class SingleChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var messageTextfield: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    var timer = Timer()
    var userName:String?
    var userId:String?
    var messageDictionary = [[String:String]]()

    
    override func viewDidLoad() {
        usernameLabel.text = userName
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        loadMessage()
        checkNewMessageTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.loadData()
    }
    
    func checkNewMessageTimer(){
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(self.loadData), userInfo: nil, repeats: true)
    }
    
    func loadData(){
        let receiverId = userId
        let currentUser = FIRAuth.auth()?.currentUser?.uid
        let reference = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("monitorChanges").child("messages").child(receiverId!).child(currentUser!)
        
        reference.observe(.value, with: { snapshot in
            if(snapshot.value as? String == "true") {
                print(snapshot)
                
                //self.messageDictionary.removeAll()
                //self.tableView.reloadData()
                //
                let monitorData = [currentUser!: "false"]
                reference.updateChildValues(monitorData)
                //self.loadMessage()
                
                //print(snapshot.value!)
                //print("true")
                //self.loadSingleMessage()
                //self.loadMessage()
                //self.tableView.reloadData()
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func goBack() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: ChatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        self.present(view, animated: true, completion: nil)
        self.timer.invalidate()
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
                let messageData = ["messageId": messageId1, "userName":username, "message": message!]
                
                self.ref.child("messages").child(messageId1).childByAutoId().setValue(messageData)
                self.ref.child("messages").child(messageId2).childByAutoId().setValue(messageData)
                // LOAD SINGLE MESSAGE 
                self.loadSingleMessage()
            }
        })
        
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
            for snap in snapshot.children {
                let message = snap as! FIRDataSnapshot
                if let snap = snapshot.value as? [String:Any]{
                    if let messageValue = message.value as? [String: String] {
                        let message = messageValue["message"]!
                        let messageId = messageValue["messageId"]!
                        let user = messageValue["userName"]!
                        
                        let messageArray = ["message" : message,
                                            "messageId": messageId,
                                            "userName": user
                        ]
                        
                        self.messageDictionary.append(messageArray)
                        self.tableView.reloadData()
                        self.setMessageIndexToBottom()
                    }
                }
            }
        })
        
        // MESSAGE ID 2
        /*ref2.observeSingleEvent(of: .value, with: { snapshot in 
         for snap in snapshot.children {
         let message = snap as! FIRDataSnapshot
         
         if let messageValue = message.value as? [String: String] {
         let message = messageValue["message"]!
         let messageId = messageValue["messageId"]!
         
         let messageArray = ["message" : message,
         "messageId": messageId
         ]
         
         self.messageDictionary.append(messageArray)
         self.tableView.reloadData()
         self.setMessageIndexToBottom()
         
         }
         }
         })*/
    }
    
    func setMessageIndexToBottom(){
        let indexPath = IndexPath(row: self.messageDictionary.count-1, section: 0) 
        self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    // FUNCTION TO LOAD SINGLE MESSAGE FROM DATABSE
    func loadSingleMessage(){
        let senderId = FIRAuth.auth()?.currentUser?.uid
        let receiverId = userId
        let messageId = ("\(senderId!+receiverId!)")
        let messageId2 = ("\(receiverId!+senderId!)")
        
        //let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("messages").queryOrdered(byChild: "messageId").queryEqual(toValue: messageId)
        
        
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("messages").child(messageId)
        // USERD .CHILDADDED TO APPEND ONE UPDATED VALUE INSTEAD OF ALL
        ref.observeSingleEvent(of: FIRDataEventType.childAdded, with: { snapshot in 
            
            if let message = snapshot.value as? [String: Any]{
                let textMessage = message["message"]! as! String
                let textMessageUser = message["userName"]! as! String
                
                let messageArray = ["message" : textMessage,
                                    "messageId": messageId,
                                    "userName": textMessageUser
                ]
                
                self.messageDictionary.append(messageArray)
                self.tableView.reloadData()
                
                self.setMessageIndexToBottom()
            }
        })
        
        /*ref2.observeSingleEvent(of: FIRDataEventType.childAdded, with: { snapshot in 
         
         if let message = snapshot.value as? [String: Any]{
         let textMessage = message["message"]! as! String
         
         let messageArray = ["message" : textMessage,
         "messageId": messageId
         ]
         
         self.messageDictionary.append(messageArray)
         self.tableView.reloadData()
         
         self.setMessageIndexToBottom()
         }
         })*/
    }
    
    
    //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
    //cell.textLabel?.textAlignment = NSTextAlignment.center
    //http://stackoverflow.com/questions/34701782/how-to-align-a-uilabel-left-or-right-in-a-uitableviewcell
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = self.messageDictionary[indexPath.row]["userName"]
        cell.detailTextLabel?.text = self.messageDictionary[indexPath.row]["message"]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageDictionary.count
    }
    
    
}
