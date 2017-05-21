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
        
        
        //tableView.rowHeight = UITableViewAutomaticDimension
        //tableView.estimatedRowHeight = 200
        self.tableView.contentInset = UIEdgeInsetsMake(35, 0, 0, 0);
        print("view did load")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numb = friendRequestsDictionary.count + 1  
        return numb
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = Bundle.main.loadNibNamed("TableViewCell", owner: self, options: nil)?.first as! TableViewCell
        let header = Bundle.main.loadNibNamed("MyEventsHeaderCell", owner: self, options: nil)?.first as! MyEventsHeaderCell
        
        if indexPath.row == 0 {
            header.backButton.addTarget(self, action: #selector(backToMenu), for: .touchUpInside)
            header.titleLabel.text = "Friend Requests"
            
            return header
        } else {
            cell.userNameLabel.text = friendRequestsDictionary[indexPath.row-1]["userName"]
            
            cell.acceptButtonOutlet.addTarget(self, action: #selector(accept), for: .touchUpInside)
            cell.declineButtonOutlet.addTarget(self, action: #selector(decline), for: .touchUpInside)
            
            cell.acceptButtonOutlet.tag = indexPath.row
            cell.declineButtonOutlet.tag = indexPath.row
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 160    
        }
        
    }
    
    func backToMenu(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        self.present(view, animated: true, completion: nil)
    }
    
    func accept(sender: UIButton){
        let ButtonTag = sender.tag
        
        let userId = friendRequestsDictionary[ButtonTag-1]["userId"]
        let userKey = friendRequestsDictionary[ButtonTag-1]["userKey"]
        let userData = [userId! : "true"]
        let acceptRequest = [ self.currentUser! : "true"]
        let randomId = ref.child("users").child(userId!).child("friends").childByAutoId().key
        
        //self.ref.child("users").child(self.currentUser!).child("friends").child(userKey!).setValue(userData)
        self.ref2.child("users").child(userId!).child("friends").child(randomId).setValue(acceptRequest){ (error, ref) -> Void in
        }
        self.ref.child("users").child(self.currentUser!).child("friends").child(userKey!).setValue(userData)
    }
    
    func decline(sender: UIButton){
        print("decline")
        
        let ButtonTag = sender.tag
        let userKey = friendRequestsDictionary[ButtonTag]["userKey"]
        self.ref.child("users").child(self.currentUser!).child("friends").child(userKey!).removeValue()
    }
}
