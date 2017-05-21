//
//  MyEventsTableController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 14/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class MyEventsTableController: UITableViewController {
    
    var eventsDictionary = [[String:String]]()
    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUserEvents()
        self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        // Do any additional setup after loading the view.
    }
    
    func loadUserEvents(){
        // retrieve user ID of currently logged in user
        let userId = FIRAuth.auth()?.currentUser?.uid
        // set the reference of the database to select the events by the user id that was provided
        let tryRef = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("events").queryOrdered(byChild: "userId").queryEqual(toValue: userId)
        // use the database reference to observe database only once as the view is loaded
        tryRef.observeSingleEvent(of: .value , with: { snapshot in
            if snapshot.value is NSNull {
                print("No records")
            } else {
                
                // if the snapshot is not empty, save the event details onto a NSDictionary
                // and reload the tableView that reloads the tableView with data that was retrieved 
                for child in (snapshot.children) {
                    let snap = child as! FIRDataSnapshot
                    let dict = snap.value as! [String: String]
                    
                    let eventsArray = ["eventName" : dict["eventName"],
                                       "userId": userId,
                                       "eventId": snap.key,
                                       "eventDate": dict["eventDate"],
                                       "eventDescription" : dict["eventDescription"],
                                       "eventCity" : dict["eventCity"],
                                        "eventPostcode" : dict["eventPostcode"]
                    ]
                    
                    
                    self.eventsDictionary.append(eventsArray as! [String: String])
                    self.tableView.reloadData()
                }
            }
        })
        
        tryRef.observeSingleEvent(of: .value, with: { snapshot in 
            
        })
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numb = self.eventsDictionary.count + 1
        return numb
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("FriendsEventsCell", owner: self, options: nil)?.first as! FriendsEventsCell
        let header = Bundle.main.loadNibNamed("MyEventsHeaderCell", owner: self, options: nil)?.first as! MyEventsHeaderCell
        
        
        if indexPath.row == 0 {
            //headerCell.joinButton.addTarget(self, action: #selector(joinChat), for: .touchUpInside)
            header.backButton.addTarget(self, action: #selector(backToMyEvents), for: .touchUpInside)
            header.titleLabel.text = "My Events"
            return header
        } else {
            cell.titleLabel.text = self.eventsDictionary[indexPath.row-1]["eventName"]!
            cell.cityLabel.text = self.eventsDictionary[indexPath.row-1]["eventCity"]!
            //cell.districtLabel.text = self.eventsDictionary[indexPath.row-1]["eventPostcode"]!
            
            self.ref.child("users").child(self.eventsDictionary[indexPath.row-1]["userId"]!).observeSingleEvent(of: .value, with: { snapshot in 
                
                if let x = snapshot.value as? [String:Any]{
                    
                    cell.districtLabel.text = "By: \(x["userName"]! as! String)"
                }    
            })

            
            cell.timeLabel.text = "Event Date"
            cell.dateLabel.text = self.eventsDictionary[indexPath.row-1]["eventDate"]!
            
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 143
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventId = self.eventsDictionary[indexPath.row-1]["eventId"]!
        //self.getSingleChatLog(eventId : eventId)
        
        //self.getSingleChatLog(eventId: eventId)
        
        if indexPath.row == 0 {
            
        } else {
            self.getSingleEvent(eventId: eventId)
        }

    }
    
    func backToMyEvents(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: EventsViewController = storyboard.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
        
        self.present(view, animated: true, completion: nil)
    }
    
    func getSingleEvent(eventId:String){
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("events").child(eventId)
        
        ref.observe(.value, with: { snapshot in
            if snapshot.value is NSNull {
                print("Empty snapshot")
            } 
            else 
            { 
                if let snapValues = snapshot.value as? [String: Any]{
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let view: SingleEventViewController = storyboard.instantiateViewController(withIdentifier: "SingleEventViewController") as! SingleEventViewController
                    
                    
                    let eventsArray = ["eventName" : snapValues["eventName"],
                                       "userId": snapValues["userId"],
                                       "eventId": eventId,
                                       "eventDate": snapValues["eventDate"],
                                       "eventDescription" : snapValues["eventDescription"],
                                       "eventCity" : snapValues["eventCity"]
                    ]
                    
                    view.eventDicionary.append(eventsArray as! [String : String])
                    view.eventName = snapValues["eventName"]! as? String
                    view.eventId = snapValues["eventId"]! as? String
                    view.adrijus = snapValues["eventName"]! as? String
                    
                    //view.eventsDictionary.append(snapValues)
                    
                    
                    //view.eventUser = snapValues["userId"]! as? String
                    //view.eventDescription = snapValues["eventDescription"]! as? String
                    self.present(view, animated: true, completion: nil) 
                }
            }
        }) 
    }
    
    
    ///////////////////////////////////
    // TRANSITION TO GROUP MESSAGING //
    ///////////////////////////////////
    
     func getSingleChatLog( eventId : String ){
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("event_messages").child(eventId)
        
        ref.observe(.value, with: { snapshot in
            print("snapshot - \(snapshot.key)")
            for snapshotValues in snapshot.children {
                let userSnap = snapshotValues as! FIRDataSnapshot
                //print(userSnap)
                self.transitionToSingleChatLog(messageId: snapshot.key)
                
                if let x = userSnap as? [String:Any] {
                    //self.transitionToSingleChatLog(userId: x["userId"]! as! String, userName: x["userName"]! as! String)
                    
                }
            }
        })
     }
    
    func transitionToSingleChatLog(messageId : String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: EventMessagesTable = storyboard.instantiateViewController(withIdentifier: "EventMessagesTable") as! EventMessagesTable
        //view.loadMessages(messageId: messageId)
        
        view.messageId = messageId
        
        self.present(view, animated: true, completion: nil) 
    }
    
    /*func transitionToSingleChatLog(userId : String, userName : String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: SingleChatViewController = storyboard.instantiateViewController(withIdentifier: "SingleChatViewController") as! SingleChatViewController
        
        view.userName = "Test"
        view.userId = "ABC-255-XX"
        
        self.present(view, animated: true, completion: nil) 
    } */
    
    
    
    


}
