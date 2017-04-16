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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.contentInset = UIEdgeInsetsMake(+36, 0, 0, 0);
        self.loadEvents()
    }
    
    func loadEvents(){
        let userId = FIRAuth.auth()?.currentUser?.uid
        let tryRef = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("events").queryOrdered(byChild: "userId").queryEqual(toValue: userId)
        
        tryRef.observeSingleEvent(of: .value , with: { snapshot in
            if snapshot.value is NSNull {
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
                                       "eventCity" : dict["eventCity"]
                    ]
                    
                    
                    self.eventsDictionary.append(eventsArray as! [String: String])
                    self.tableView.reloadData()
                    print(self.eventsDictionary)
                }
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventsDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("FriendsEventsCell", owner: self, options: nil)?.first as! FriendsEventsCell
        
        cell.titleLabel.text = self.eventsDictionary[indexPath.row]["eventName"]!
        cell.districtLabel.text = "Essex"
        cell.timeLabel.text = "12 : 15"
        cell.dateLabel.text = self.eventsDictionary[indexPath.row]["eventDate"]!
        cell.cityLabel.text = self.eventsDictionary[indexPath.row]["eventCity"]!
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    

   

}
