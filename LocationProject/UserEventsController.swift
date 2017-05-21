//
//  EventsViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 14/02/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class UserEventsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    
    var eventsDictionary = [[String:String]]()
    var eventsModel: Events?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.eventsModel == nil {
            self.eventsModel = Events()
        }
        
        print("asodnjoasndjansjdknajsk")
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.loadUserEvents()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func transition(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    @IBAction func addEvent() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: AddEventsViewController = storyboard.instantiateViewController(withIdentifier: "AddEventsViewController") as! AddEventsViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    // Load event data created by the user
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
                
                    self.eventsModel?.eventsDictionary.append(eventsArray as! [String: String])
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    @IBAction func showInfo() {
        print("button")
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return self.eventsDictionary.count
        return (self.eventsModel?.eventsDictionary.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")!
        //cell.textLabel?.text = self.eventsDictionary[indexPath.row]["eventName"]
        cell.textLabel?.text = self.eventsModel?.eventsDictionary[indexPath.row]["eventName"]

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //let eventId = self.eventsDictionary[indexPath.row]["eventId"]!
        let eventId = self.eventsModel?.eventsDictionary[indexPath.row]["eventId"]!
        // PUSH VIEW FOR SELECTED EVENT
        self.getSingleEvent(eventId: eventId!)        
    }
    
    //  Load single event details and push it to view
    func getSingleEvent(eventId:String){
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("events").child(eventId)
        
        print("event id \(eventId)")
        
        ref.observe(.value, with: { snapshot in  
            if snapshot.value is NSNull {
                print("Empty snapshot")
            } 
            else 
            {
                print("SNAP V - \(snapshot.value)")
                
                if let snapValues = snapshot.value as? [String: Any]{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let view: SingleEventViewController = storyboard.instantiateViewController(withIdentifier: "SingleEventViewController") as! SingleEventViewController
                    
                    view.eventName = snapValues["eventName"]! as? String
                    //
                    //view.eventsArray = Array(snapValues.values) as! [String]
                    //view.eventsDictionary.append(snapValues)
                    //view.eventsDictionary = snapValues

                    //view.eventUser = snapValues["userId"]! as? String
                    //view.eventDescription = snapValues["eventDescription"]! as? String
                    self.present(view, animated: true, completion: nil) 
                }
            }
        }) 
    }
    
    @IBAction func showMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        self.present(view, animated: true, completion: nil)
    }

    
    
    
}
