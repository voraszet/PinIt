//
//  FriendRequestTableViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 13/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class FriendRequestTableViewController: UITableViewController {
    
    var friendRequestsDictionary = [[String:String]]()
    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let ref2 = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 200
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequestsDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        
        cell.userNameLabel.text = friendRequestsDictionary[indexPath.row]["userName"]
        
        cell.acceptButtonOutlet.addTarget(self, action: #selector(accept), for: .touchUpInside)
        cell.declineButtonOutlet.addTarget(self, action: #selector(decline), for: .touchUpInside)
        
        cell.acceptButtonOutlet.tag = indexPath.row
        cell.declineButtonOutlet.tag = indexPath.row
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    
    func ha(){
        print("ha!")
    }
    
    
    func accept(sender: UIButton){
        print("accept")
        let ButtonTag = sender.tag
        
        let userId = friendRequestsDictionary[ButtonTag]["userId"]
        let userKey = friendRequestsDictionary[ButtonTag]["userKey"]
        let userData = [userId! : "true"]
        let acceptRequest = [ self.currentUser! : "true"]
        
        //self.ref.child("users").child(self.currentUser!).child("friends").child(userKey!).setValue(userData)
        self.ref.child("users").child(self.currentUser!).child("friends").child(userKey!).setValue(userData)
        self.ref2.child("users").child(userId!).child("friends").childByAutoId().setValue(acceptRequest){ (error, ref) -> Void in
            
            
            
            
            self.friendRequestsDictionary.remove(at: ButtonTag)
            self.tableView.reloadData()
            
            if self.friendRequestsDictionary.count < 1 {
                self.friendRequestsDictionary.removeAll()
            }
        }

    }
    
    func decline(sender: UIButton){
        print("decline")
        
        let ButtonTag = sender.tag
        let userKey = friendRequestsDictionary[ButtonTag]["userKey"]
        self.ref.child("users").child(self.currentUser!).child("friends").child(userKey!).removeValue()
    }
    
    
    
    
    
}
