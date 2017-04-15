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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loadUserEvents()

        // Do any additional setup after loading the view.
    }
    
    func loadUserEvents(){
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
        let cell = Bundle.main.loadNibNamed("MyEventsCell", owner: self, options: nil)?.first as! MyEventsCell
        
        cell.titleLabel.text = self.eventsDictionary[indexPath.row]["eventName"]!
        cell.cityLabel.text = self.eventsDictionary[indexPath.row]["eventCity"]!
        cell.districtLabel.text = "Essex"
        cell.timeLabel.text = "12 : 00"
        cell.dateLabel.text = self.eventsDictionary[indexPath.row]["eventDate"]!
        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
    
    
    


}
