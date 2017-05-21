//
//  EventMessagesTable.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 18/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase


class EventMessagesTable: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var messageTextbox: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var tView: UITableView!
    
    
    var messageDictionary = [[String:String]]()
    
    var messageId:String = ""
    var eventNameString:String = ""
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        titleLabel.text = self.eventNameString
        
        self.tView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tView.delegate = self
        tView.dataSource = self
        
        tView.rowHeight = UITableViewAutomaticDimension
        tView.estimatedRowHeight = 140
        tView.separatorStyle = .none
        
        self.loadMessages()
        self.loadSingleMessage()
        
        //self.load()
        
    }

    
    func loadMessages(){
        let msgRef = self.ref.child("event_messages").child(messageId)
        
        msgRef.observeSingleEvent(of: .value, with: { snapshot in 
        self.messageDictionary.removeAll()
            
            for snap in snapshot.children {
                let message = snap as! FIRDataSnapshot
                if let snap = message.value as? [String:Any]{
                    //print(snap["message"]!)
                    
                    let messageArray = ["message" : snap["message"]!,
                                        "userName": snap["userName"]!,
                                        "userId": snap["userId"]
                    ]
                    
                    self.messageDictionary.append(messageArray as! [String : String])
                }
                self.tView.reloadData()
            }
            self.setMessageIndexToBottom()
        })
    }
    
    
    func setMessageIndexToBottom(){
        let indexPath = IndexPath(row: self.messageDictionary.count-1, section: 0) 
        
        if(self.messageDictionary.count > 0){
            self.tView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
    }
    
    @IBAction func sendMessage() {
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
    
    // Real-time messsage synchronization
    func loadSingleMessage(){
        // Select a specific 'event_messages' table that is used for a group chat
        // query the snapshot by only retrieving the last snapshot
        // use 'childAdded' event type to synchronize data whenever values are added at specified database path
        // in this case, it would observe only the last messages that were added to a database
        self.ref.child("event_messages").child(self.messageId).queryLimited(toLast: 1).observe(.childAdded, with: { snapshot in
            // convert the message from JSON to NSDictionary
            // the messages are appended onto UITableView which is used to
            // display messages in a hierarchical list
            if let message = snapshot.value as? [String: Any]{
                let textMessage = message["message"]! as! String
                let textMessageUser = message["userName"]! as! String
                let id = message["userId"]! as! String
                
                let messageArray = ["message" : textMessage,
                                    "userName": textMessageUser,
                                    "userId" : id
                ]
                // append the message NSArray to NSDictionary 
                self.messageDictionary.append(messageArray)
                // reload the UITableView, so the new incoming messages reload at specified index
                self.tView.reloadData()
                // scroll the view to bottom as new messages appear
                self.setMessageIndexToBottom()
                
                print("message array \(messageArray)")
            }
        })
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        /*let  cell = Bundle.main.loadNibNamed("EventMessageCell", owner: self, options: nil)?.first as! EventMessageCell
        
        cell.textLabel?.text = self.messageDictionary[indexPath.row]["message"]
        
        return cell */
        
        
        let uId = self.messageDictionary[indexPath.row]["userId"]
        
 
        
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
 


}
