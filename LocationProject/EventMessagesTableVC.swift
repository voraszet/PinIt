//
//  EventMessagesTableVC.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 17/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class EventMessagesTableVC: UITableViewController {

    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    var messageDictionary = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableViewAutomaticDimension
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadMessages(messageId : String){
        self.ref.child("event_messages").child(messageId).observe(.value, with: { snapshot in 
            
        })
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.messageDictionary.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let  header = Bundle.main.loadNibNamed("CustomHeaderCell", owner: self, options: nil)?.first as! CustomHeaderCell
        

        header.titleLabel.text = "Running"
        
        return header
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  cell = Bundle.main.loadNibNamed("EventMessageCell", owner: self, options: nil)?.first as! EventMessageCell
        
        return cell
    } 
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}
