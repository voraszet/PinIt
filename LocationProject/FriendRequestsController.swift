//
//  FriendRequestsController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 13/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit

class FriendRequestsController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var friendRequestsDictionary = [[String:String]]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friendRequestsDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.text = self.friendRequestsDictionary[indexPath.row]["userName"]
        //cell.detailTextLabel?.text = self.friendRequestsDictionary[indexPath.row]["userId"] 
        cell.detailTextLabel?.text = self.friendRequestsDictionary[indexPath.row]["userEmail"]

        return cell
    }

    


}
