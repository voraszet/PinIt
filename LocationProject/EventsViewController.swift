//
//  EventsViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 14/02/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class EventsViewController: UIViewController {
    
    var ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    var eventRequest:String?
    var eventIdArray:[String]?
    
    var flag:Bool = false
    
    
    var dictionary = [[String:String]]()
    
    @IBOutlet weak var eventRequestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.eventRequestLabel.text = self.eventRequest
        self.eventRequestLabel.layer.masksToBounds = true
        self.eventRequestLabel.layer.cornerRadius = 5
        
        self.loadMyEventIds()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    

    //SHOW CURRENT USER EVENTS
    @IBAction func showUserEvents() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: MyEventsTableController = storyboard.instantiateViewController(withIdentifier: "MyEventsTableController") as! MyEventsTableController
        self.present(view, animated: true, completion: nil)
    }
    
    //SHOW EVENTS OF YOUR FRIENDS
    @IBAction func showFriendsEvents() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: MyFriendsEventsTableViewTableViewController = storyboard.instantiateViewController(withIdentifier: "MyFriendsEventsTableViewTableViewController") as! MyFriendsEventsTableViewTableViewController
        self.present(view, animated: true, completion: nil)
    }
    
    
    @IBAction func showMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    @IBAction func addEvents() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: AddEventsViewController = storyboard.instantiateViewController(withIdentifier: "AddEventsViewController") as! AddEventsViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    @IBAction func showEventRequests(_ sender: Any) {
        //self.loadERView()
        self.loadFriendRequests()
        //self.loadERView()
    }
    
    func loadMyEventIds(){
        self.ref.child("events").queryOrdered(byChild: "userId").queryEqual(toValue: currentUser!).observe(.value, with: { snapshot in 
            for snap in snapshot.children {
                let FIRSnap = snap as! FIRDataSnapshot
                
                if let snapDict = FIRSnap.value as? [String:String]{
                    var eventIds = snapDict["eventId"]!
                    self.loadEventRequests(eventId: eventIds)
                } 
            }
        })
    }
    
    func loadEventRequests(eventId : String){
        var eventRequestCount:Int = 0
        var userIds:String?
        
        self.ref.child("event_friends").child(eventId).observe(.value, with: { snapshot in
            for snap in snapshot.children {
                let FIRSnap = snap as! FIRDataSnapshot
                
                if let snapDict = FIRSnap.value as? [String : Any] {
                    for loopDict in snapDict {
                        let bool = loopDict.value as? String
                        
                        if bool == "false" {
                            userIds = loopDict.key
                            eventRequestCount = eventRequestCount + 1
                            self.eventRequestLabel.text = String(eventRequestCount)
                            
                            // This function is called twice
                            //self.loadEventRequestView(userIds: userIds!, key:FIRSnap.key, eventId:eventId)
                        }
                    }
                
                }
                
            }
            eventRequestCount = 0
        }) 
    }
    
    ///////
    
    func loadFriendRequests(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: EventRequestsTableView = storyboard.instantiateViewController(withIdentifier: "EventRequestsTableView") as! EventRequestsTableView
        
        self.ref.child("events").queryOrdered(byChild: "userId").queryEqual(toValue: currentUser!).observe(.value, with: { snapshot in 4
            for snap in snapshot.children{
                let FIRSnap = snap as! FIRDataSnapshot
                
                if let snapDict = FIRSnap.value as? [String:String] {
                    let eventIds = snapDict["eventId"]!
                    
                    self.ref.child("event_friends").observe(.value, with: { snapshot in

                        self.dictionary.removeAll()
                        self.flag = false
                        view.eventRequestsDictionary.removeAll()
                        
                        for secondSnap in snapshot.children {
                            let FIRSnapSecond = secondSnap as! FIRDataSnapshot
 
                            let ids = FIRSnapSecond.key
                            
                            if let snapDict = FIRSnapSecond.value as? [String:Any]{

                                // if event matches my events
                                
                                if ids == eventIds {
                                    let FIRSnap = snap as! FIRDataSnapshot
                                        for loopDict in snapDict {
                                        
                                            let friendRequestSnap = loopDict.value as? [String:Any]
                                            let test = loopDict.value as? String
                                            let bool = friendRequestSnap!.first!.value as? String
                                            let friendId = friendRequestSnap!.first!.key as? String
                                            
                                            let x = loopDict.value as? [String:Any]
                                            let uID = x!["userId"]! as? String
                                            let b = x?[uID!] as? String
                                            
                                            print("BOOL - \(uID!)")
                                            
                                            if (b == "false") {
                                                self.flag = true
                                                self.ref.child("users").child(uID!).observe(.value, with: { snapshot in 
                                                    
                                                    let value = snapshot.value as? NSDictionary
                                                    let username = value?["userName"] as? String ?? ""
                                                        self.ref.child("events").child(eventIds).observe(.value, with: { snapshot in 
                                                            
                                                            let x = snapshot.value as? NSDictionary
                                                            let eventName = x?["eventName"] as? String ?? "" 
                                                            
                                                            let data = ["userName": username,
                                                                        "userId": uID!,
                                                                        "userEmail": value?["userEmail"] as? String ?? "",
                                                                        "key": FIRSnap.key,
                                                                        "eventId" : snapshot.key,
                                                                        "eventName" : eventName
                                                            ]
                                                            
                                                            view.eventRequestsDictionary.append(data as! [String : String])
                                                            print("Inner dictionary - \(view.eventRequestsDictionary.count)")
                                                            print("--------------------------------------------------")
                                                            
                                                            view.tableView.reloadData()
                                                        })       
                                                })   
                                            }
                                        }
                                }
                                if !self.flag {
                                    view.eventRequestsDictionary.removeAll()
                                    view.tableView.reloadData()
                                }
                            }
                        }
                    })
                }
            }
        
        })
        
        self.present(view, animated: true, completion: nil)
        
    }
    
    
    
    
    func loadERView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: EventRequestsTableView = storyboard.instantiateViewController(withIdentifier: "EventRequestsTableView") as! EventRequestsTableView
        
        self.ref.child("events").queryOrdered(byChild: "userId").queryEqual(toValue: currentUser!).observe(.value, with: { snapshot in
            
            for snap in snapshot.children {
                
                let FIRSnap = snap as! FIRDataSnapshot
                //view.eventRequestsDictionary.removeAll()
                if let snapDict = FIRSnap.value as? [String:String]{
                    let eventIds = snapDict["eventId"]!
                    
                    self.ref.child("event_friends").child(eventIds).observe(.value, with: { snapshot in
                        view.eventRequestsDictionary.removeAll()
                        
                        for snap in snapshot.children {
                            let FIRSnap = snap as! FIRDataSnapshot
                            print("//////////////////////////////////")
                            print(snap)
                            print("//////////////////////////////////")
                            //view.eventRequestsDictionary.removeAll()
                            if let snapDict = FIRSnap.value as? [String : Any] {
                                for loopDict in snapDict {
                                    let bool = loopDict.value as? String

                                    if bool == "false" {
                                        
                                        let userIds = loopDict.key
                                        
                                        //self.eventRequestLabel.text = String(eventRequestCount)
                                        self.ref.child("users").child(userIds).observe(.value, with: { snapshot in 
                                            
                                            let value = snapshot.value as? NSDictionary
                                            let username = value?["userName"] as? String ?? "" 
                                            
                                            let data = ["userName": username,
                                                        "userId": userIds,
                                                        "userEmail": value?["userEmail"] as? String ?? "",
                                                        "key": FIRSnap.key
                                            ]
                                            // moved from here
                                            //view.eventRequestsDictionary.append(data)
                                            //view.tableView.reloadData()
                                            
                                            
                                            self.ref.child("events").child(eventIds).observe(.value, with: { snapshot in 
                                                
                                                let x = snapshot.value as? NSDictionary
                                                let eventName = x?["eventName"] as? String ?? "" 
                                                
                                                let data = ["userName": username,
                                                            "userId": userIds,
                                                            "userEmail": value?["userEmail"] as? String ?? "",
                                                            "key": FIRSnap.key,
                                                            "eventId" : snapshot.key,
                                                            "eventName" : eventName
                                                ]
                                                
                                                view.eventRequestsDictionary.append(data)
                                                print("Inner dictionary - \(view.eventRequestsDictionary.count)")
                                                print("--------------------------------------------------")
                                                
                                                view.tableView.reloadData()
                                            })
                                        })
                                    }
                                }
                                
                            }
                        }
                    })
                } 
            }
        })
        self.present(view, animated: true, completion: nil)
    }
}
