//
//  MyFriendsEventsTableViewTableViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 16/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class MyFriendsEventsTableViewTableViewController: UITableViewController {
    
    var eventsDictionary = [[String:String]]()
    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        
        //self.loadEvents()
        self.friendEventList()
    }
    
    func loadEvents(){
        let userId = FIRAuth.auth()?.currentUser?.uid
        let tryRef = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("events").queryOrdered(byChild: "userId").queryEqual(toValue: userId)
        
        tryRef.observeSingleEvent(of: .value , with: { snapshot in
            /*if snapshot.value is NSNull {
                print("empty records")
            } else {
                for child in (snapshot.children) {
                    let snap = child as! FIRDataSnapshot
                    let dict = snap.value as! [String: String]
                    
                    let eventsArray = ["eventName" : dict["eventName"],
                                       "userId": userId,
                                       "eventId": snap.key,
                                       "eventDate": dict["eventDate"],
                                       "eventDescription" : dict["eventDescription"],
                                       "eventCity" : dict["eventCity"],
                                       "eventPostcode" : "PAPAPA"
                                       
                    ]
                    
                    
                    self.eventsDictionary.append(eventsArray as! [String: String])
                    
                    print("DICT \(self.eventsDictionary)")
                    self.tableView.reloadData()
                }
            } */
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
        
        //let eventId = self.eventsDictionary[indexPath.row]["eventId"]!
        if indexPath.row == 0 {
            header.backButton.addTarget(self, action: #selector(backToEvents), for: .touchUpInside)
            header.titleLabel.text = "My Friends Events"
            return header
        } else {
            cell.statusButton.addTarget(self, action: #selector(self.checkEventId), for: .touchUpInside)
            cell.statusButton.tag = indexPath.row
            
            cell.titleLabel.text = self.eventsDictionary[indexPath.row-1]["eventName"]!
            //cell.districtLabel.text = self.eventsDictionary[indexPath.row-1]["eventPostcode"]!
            cell.districtLabel.text = "USERRRR"
            //
            self.ref.child("users").child(self.eventsDictionary[indexPath.row-1]["userId"]!).observeSingleEvent(of: .value, with: { snapshot in 
                
                if let x = snapshot.value as? [String:Any]{
                    print(x["userName"]!)
                    cell.districtLabel.text = "By: \(x["userName"]! as! String)"
                }    
            })

            cell.timeLabel.text = "Date"
            cell.dateLabel.text = self.eventsDictionary[indexPath.row-1]["eventDate"]!
            cell.cityLabel.text = self.eventsDictionary[indexPath.row-1]["eventCity"]!
            return cell
        }
            
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 150
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventId = self.eventsDictionary[indexPath.row-1]["eventId"]!
        self.getSingleEvent(eventId: eventId)
    }
    
    func backToEvents(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: EventsViewController = storyboard.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
        
        self.present(view, animated: true, completion: nil)
    }
    
    func friendEventList(){
        self.ref.child("users").child(self.currentUser!).child("friends").observe(.value, with: { snapshot in 
            //self.usersDictionary.removeAll()
            
            for snap in snapshot.children {    
                let keyValueSnap = snap as! FIRDataSnapshot
                print(keyValueSnap.key)
                	
                if let x = keyValueSnap.value as? [String:Any] {
                    let friendBooleanValue = x.first!.value as? String
                    
                    if friendBooleanValue == "true" {
                        let friendId = x.first!.key
                        
                        self.loadFriendEvents(userId : friendId)
                    }
                }    
            }
        })
    }
    
    func loadFriendEvents(userId : String) {
        self.ref.child("events").queryOrdered(byChild: "userId").queryEqual(toValue: userId).observe(.value, with: { snapshot in 
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
        })
    }
    
    func checkEventId(sender: UIButton){
        let tag = sender.tag
        print(tag)
    } 
    
    //  Load single event details and push it to view
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
                                       "eventCity" : snapValues["eventCity"],
                                       "eventPostcode" : snapValues["eventPostcode"]
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
    

    

   

}
