//
//  EventRequestsTableView.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 20/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class EventRequestsTableView: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var eventNamesDictionary = [[String:String]]()
    var eventRequestsDictionary = [[String:String]]()
    
    var ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("event dictionary \(eventRequestsDictionary)")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = Bundle.main.loadNibNamed("EventRequestCell", owner: self, options: nil)?.first as! EventRequestCell
        let header = Bundle.main.loadNibNamed("MyEventsHeaderCell", owner: self, options: nil)?.first as! MyEventsHeaderCell
        
        if indexPath.row == 0 {
            header.titleLabel.text = "Event Requests"
            header.backButton.addTarget(self, action: #selector(backToEvents), for: .touchUpInside)
            return header
        } else {
            cell.eventUser.text = self.eventRequestsDictionary[indexPath.row-1]["userName"]
            cell.eventTitleLabel.text = self.eventRequestsDictionary[indexPath.row-1]["eventName"]
            //cell.eventTitleLabel.text = self.eventNamesDictionary[indexPath.row]["eventName"]
            cell.acceptButton.addTarget(self, action: #selector(acceptEventRequest), for: .touchUpInside)
            cell.acceptButton.tag = indexPath.row
            
            cell.declineButton.addTarget(self, action: #selector(declineEventRequest), for: .touchUpInside)
            cell.declineButton.tag = indexPath.row
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 100
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numb = eventRequestsDictionary.count + 1 
        return numb
    }
    
    func backToEvents(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: EventsViewController = storyboard.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
        self.present(view, animated: true, completion: nil)
    }
    
    func acceptEventRequest(sender: UIButton){
        
        let userId = self.eventRequestsDictionary[sender.tag-1]["userId"]!
        let eventId = self.eventRequestsDictionary[sender.tag-1]["eventId"]!
        let acceptRequestData = [ userId : "true", "userId": userId]
        
        self.ref.child("event_friends").child(eventId).queryOrdered(byChild: "userId").queryEqual(toValue: userId).observeSingleEvent(of: .value, with: { snapshot in 
            
            if let x = snapshot.value as? [String: Any] {
                print(x.first!.key)
                
                self.ref.child("event_friends").child(eventId).child(x.first!.key).updateChildValues(acceptRequestData)
                
            }
            
        })
    }
    
    func declineEventRequest(sender: UIButton){
        print(sender.tag)
        
    }


}
