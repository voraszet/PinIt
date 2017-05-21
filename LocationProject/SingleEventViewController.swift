//
//  EventsViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 14/02/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class SingleEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var eventDicionary = [[String:String]]()
    var membersDictionary = [[String:String]]()
    
    
    var eventName:String?
    var eventDescription:String?
    var eventId:String?
    var memberIdArray:[String]?
    
    var adrijus:String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.loadGroupMembers()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount:Int = Int(self.membersDictionary.count) + 2
        return rowCount
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        
        
        // INDEX 0
        if indexPath.row == 0 {
            let headerCell = Bundle.main.loadNibNamed("SingleEventHeaderCell", owner: self, options: nil)?.first as! SingleEventHeaderCell
            
            headerCell.joinButton.addTarget(self, action: #selector(joinChat), for: .touchUpInside)
            
            let data = [ currentUser! : "false", "userId" : currentUser!]
            
            self.ref.child("event_friends").child(eventId!).queryOrdered(byChild: "userId").queryEqual(toValue: currentUser!).observe(.value, with: { snapshot in
                if snapshot.value is NSNull {

                } else {
                    headerCell.joinButton.setTitle("Pending", for: .normal)
                    headerCell.joinButton.setTitleColor(.gray, for: .normal)
                    print("you have already sent group request")
                }
            })
            
            self.ref.child("event_friends").child(eventId!).observe(.value, with: { snapshot in 
                for snap in snapshot.children {
                    let FIRSnap = snap as! FIRDataSnapshot
                    
                    if let snapDict = FIRSnap.value as? [String : Any] {
                        for loopDict in snapDict {
                            
                            var keys = loopDict.key
                            let bool = loopDict.value as? String
                            
                            if (keys == self.currentUser){
                                if (bool == "true") {
                                    //memberCell.chatButton.setTitleColor(.green, for: .normal)
                                    headerCell.joinButton.isHidden = true
                                }
                                if (bool == "false") {
                                    headerCell.joinButton.isHidden = false
                                    headerCell.joinButton.setTitle("Pending", for: .normal)
                                    
                                }
                            }
                        }
                    }
                }
            })
            
            
            headerCell.eventTitle.text = self.eventName
            headerCell.eventDescription.text = self.eventDicionary[indexPath.row]["eventDescription"]
            //headerCell.eventDistrict.text = self.eventDicionary[indexPath.row]["eventPostcode"]
            //headerCell.eventDistrict.text = self.eventDicionary[indexPath.row]["userId"]
            
            self.ref.child("users").child(self.eventDicionary[indexPath.row]["userId"]!).observeSingleEvent(of: .value, with: { snapshot in 
            
                if let x = snapshot.value as? [String:Any]{
                    print(x["userName"]!)
                    headerCell.eventDistrict.text = "By: \(x["userName"]! as! String)"
                }    
            })
            
            headerCell.eventCity.text = self.eventDicionary[indexPath.row]["eventCity"]
            
            headerCell.eventTimeLabel.text = self.eventDicionary[indexPath.row]["eventDate"]
            
            return headerCell
            
        // INDEX 1    
        } else if indexPath.row == 1 {
            let memberCell = Bundle.main.loadNibNamed("MembersHeaderCell", owner: self, options: nil)?.first as! MembersHeaderCell
            
            memberCell.chatButton.addTarget(self, action: #selector(loadChat), for: .touchUpInside)
            
            self.ref.child("event_friends").child(eventId!).observe(.value, with: { snapshot in 
                for snap in snapshot.children {
                    let FIRSnap = snap as! FIRDataSnapshot
                    
                    if let snapDict = FIRSnap.value as? [String : Any] {
                        for loopDict in snapDict {
                            
                            var keys = loopDict.key
                            let bool = loopDict.value as? String
                            
                            if (keys == self.currentUser){
                                if (bool == "true") {
                                    memberCell.chatButton.setTitleColor(.green, for: .normal)
                                }
                                if(bool == "false"){
                                    memberCell.chatButton.setTitle("Join Chat", for: .normal)
                                    memberCell.chatButton.setTitleColor(.red, for: .normal)      
                                }
                            }
                            
                            //
                            // host auto chat enabled here
                            //
                        }
                    }
                }
            })
            
            return memberCell
        // INDEX 2 +   
        } else {
            let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
            
            cell.textLabel?.text = self.membersDictionary[indexPath.row - 2]["userName"]

            print("memb \(membersDictionary)")
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 245
        } else if indexPath.row == 1 {
            return 60
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func loadChat(){
        print("looading chat")
        self.getSingleChatLog(eventId: eventId!)
        
        
    }
    
    
    @IBAction func goToUserView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController        
        self.present(view, animated: true, completion: nil)
    }
    
    func joinChat(){
        let cell = Bundle.main.loadNibNamed("SingleEventHeaderCell", owner: self, options: nil)?.first as! SingleEventHeaderCell
        
        let data = [ currentUser! : "false", "userId" : currentUser!]
        
        self.ref.child("event_friends").child(eventId!).queryOrdered(byChild: "userId").queryEqual(toValue: currentUser!).observeSingleEvent(of: .value, with: { snapshot in
            if snapshot.value is NSNull {
                self.ref.child("event_friends").child(self.eventId!).childByAutoId().setValue(data)
                
                print("event request is sent")
            } else {
                
                print("you have already sent group request")
            }
        })
        
        // RELOAD CUSTOM CELL
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.reloadRows(at: [indexPath], with: .fade)
        tableView.reloadData() 
    }
    
    
    func loadGroupMembers(){
        let secondCell = Bundle.main.loadNibNamed("MembersHeaderCell", owner: self, options: nil)?.first as! MembersHeaderCell
        
        
        self.ref.child("event_friends").child(eventId!).observe(.value, with: { snapshot in
            self.membersDictionary.removeAll()
            
            for snap in snapshot.children {
                let FIRSnap = snap as! FIRDataSnapshot
                
                if let snapDict = FIRSnap.value as? [String : Any] {
                    for loopDict in snapDict {
                        let bool = loopDict.value as? String
                        if bool == "false" {
                            // "false" for pending event requests
                            var keys = loopDict.key
                            
                        } else if bool == "true" {
                            // "true" for accepted users to events (members)
                            let userIds = loopDict.key
                            //print("true users \(userIds)")
                            
                            self.ref.child("users").child(userIds).observe(.value, with: { snapshot in 
                                let value = snapshot.value as?  NSDictionary
                                let username = value?["userName"] as? String ?? ""
                                let userId = value?["userId"] as? String ?? ""
                                
                                let data = [ "userName" : username,
                                             "userId" : userId
                                ] 
                                self.membersDictionary.append(data)
                                //
                                //self.tableView.delegate = self
                                //self.tableView.dataSource = self
                                
                                //
                                self.tableView.reloadData()
                                
                            })
                            
                            if (self.currentUser == loopDict.key){
                                print("JUlius is in")
                                
                                //can chat now if "true"
                                
                            }
                            
                            print("looopdictkey - \(loopDict.key)")
                            
                            
                            
                        }
                    }
                }
            }
        })
    }
    
    
    ////
    func getSingleChatLog( eventId : String ){
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("event_messages").child(eventId)
        
        self.ref.child("event_friends").child(eventId).observeSingleEvent(of: .value, with: { snapshot in 
            for snap in snapshot.children {
                let FIRSnap = snap as! FIRDataSnapshot
                
                if let snapDict = FIRSnap.value as? [String : Any] {
                    for loopDict in snapDict {
                        
                        var keys = loopDict.key
                        let bool = loopDict.value as? String
                        
                        if (bool == "true"){
                            if (loopDict.key == self.currentUser){
                                print("You are a member")
                                self.transitionToSingleChatLog(eventId: eventId)
                            }
                        } else {
                            if (loopDict.key == self.currentUser){
                                print("You are not a member of a group")
                            }   
                        }
                    }
                }
            }
        })
    }
    
    func transitionToSingleChatLog(eventId : String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // changes here
        //let view: EventMessagesTable = storyboard.instantiateViewController(withIdentifier: "EventMessagesTable") as! EventMessagesTable
        let view: ChatVC = storyboard.instantiateViewController(withIdentifier: "ChatVC") as! ChatVC
        
        let vc = ChatTableView()
        
        
        
        
        //view.loadMessages(messageId: messageId)
        
        view.messageId = eventId
        
        //view.titleLabel.text = "EventName"
        self.ref.child("events").child(eventId).observeSingleEvent(of: .value, with: { snapshot in 
            if let snapValues = snapshot.value as? [String: Any]{
                
                //view.title = 
                //view.title = "hi"
                //view.titleLabel.text = snapValues["eventName"] as! String?
                view.eventNameString = snapValues["eventName"]! as! String
                
                
                
                
                vc.messageId = eventId
                
                
                self.present(view, animated: true, completion: nil)
                    
            }
        })
         
    }
    
    
    
    
    
    
    
    
    
}
