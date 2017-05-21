//
//  MenuViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 07/02/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase



class MenuViewController: UIViewController {
    
    //@IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var friendRequests: UILabel!
    
    var usernameString:String = ""
    var friendReq:String = ""
    
    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    //  EVENTS VIEW
    @IBAction func loadEventsView(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: EventsViewController = storyboard.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
        
        self.present(view, animated: true, completion: nil)
    }
    //  MAP VIEW
    @IBAction func loadMapView(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: MapViewController = storyboard.instantiateViewController(withIdentifier: "MapViewController") as! MapViewController
        self.present(view, animated: true, completion: nil)
    }
    
    //  CHAT VIEW
    @IBAction func loadFriendsView(_ sender: AnyObject) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: ChatViewController = storyboard.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    
    @IBAction func loadFriendsBtn() {
        // Allocate UIStoryboard to set the storyboard of a project
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        // Connect Friend-Request UIViewController to storyboard
        let view: FriendRequestTableViewController = storyboard.instantiateViewController(withIdentifier: "FriendRequestTableViewController") as! FriendRequestTableViewController
        // Specify users table as a database reference
        self.ref.child("users").child(self.currentUser!).child("friends").observe(.value, with: { snapshot in 
            // these two lines are new
            view.friendRequestsDictionary.removeAll()
            view.tableView.reloadData()
            //
            for snap in snapshot.children {
                let keyValueSnap = snap as! FIRDataSnapshot
                
                if let keyValue = keyValueSnap.value as? [String:Any] {
                    let friendBooleanValue = keyValue.first!.value as? String
                    
                    if friendBooleanValue == "false" {
                        let userId = keyValue.first!.key                        
                        
                        self.ref.child("users").child(userId).observe(.value, with: { snapshot in 
                            if snapshot.value is NSNull{
                                print("empty")
                            } else {
                                //let key = keyValueSnap.key
                                let value = snapshot.value as?  NSDictionary
                                let username = value?["userName"] as? String ?? ""
                                let data = ["userName": username,
                                            "userId": userId,
                                            "userEmail": value?["userEmail"] as? String ?? "",
                                            "userKey" : keyValueSnap.key
                                ]
                                
                                view.friendRequestsDictionary.append(data)
                                view.tableView.reloadData()
                            }
                        })
                    }
                } 
            }
        })
        
        self.present(view, animated: true, completion: nil)        
    }
    
    
    
    override func viewDidLoad() {
        //setUsername()
        self.usernameLabel.text = self.usernameString
        self.friendRequests.text = self.friendReq
        
        // Rounded label border-radius
        self.friendRequests.layer.masksToBounds = true
        self.friendRequests.layer.cornerRadius = 5
        
        
        
        super.viewDidLoad()
        
    }
    
    @IBAction func showNewTableView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: FriendRequestTableViewController = storyboard.instantiateViewController(withIdentifier: "FriendRequestTableViewController") as! FriendRequestTableViewController
        self.present(view, animated: true, completion: nil)

    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.loadFriendRequests()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //  SET USERNAME
    func setUsername(){
        let currentUserId = FIRAuth.auth()?.currentUser?.uid
        let ref  = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("users").child(currentUserId!)
        
        ref.observeSingleEvent(of: .value, with: { snapshot in 
            if let username = snapshot.value as? [String: Any]{
                self.usernameLabel.text = username["userName"]! as? String
            }
        })
    }
    func returnToMainPage(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        self.present(view, animated: true, completion: nil)
    }
    
    // Loading the count of number requests in real-time
    func loadFriendRequests(){
        // set friend request count to 0
        var friendRequestCount:Int = 0
        // select the users table from a database and query the snapshot with the currently logged in user's id
        // set the database listener to 'observe' to constantly monitor changes at specified database path
        // set the event type to 'value' to load all snapshots at specified database path
        ref.child("users").child(self.currentUser!).child("friends").observe(.value, with: { snapshot in
            // loop through the snapshots, e.g. a list of friend requests
            for snap in snapshot.children {
                let keyValueSnap = snap as! FIRDataSnapshot
                // convert the JSON object into NSDictionary
                if let keyValue = keyValueSnap.value as? [String:Any] {
                    // note that that NSDictionary allows us to access 'key & value' values
                    // the 'keyValue' variable now holds User ID and Boolean 'true' or 'false' values
                    let friendBooleanValue = keyValue.first!.value as? String
                    
                    // doing a check, if the current snapshot value is false
                    // increment friend request count by one
                    if friendBooleanValue == "false" {
                        friendRequestCount = friendRequestCount + 1
                        // set the amount of friend requests to UILabel
                        self.friendRequests.text = String(friendRequestCount)
                    }
                }  
            }
            friendRequestCount = 0
        })
    }
    
    
    @IBAction func signoutButton(_ sender: AnyObject) {
        try! FIRAuth.auth()!.signOut()
        
        returnToMainPage()
    }
    
}
