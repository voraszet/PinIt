//
//  EventMessagesTableVC.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 17/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit

class EventMessagesTableVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = Bundle.main.loadNibNamed("EventMessageCell", owner: self, options: nil)?.first as! EventMessageCell
        
        
        return cell
    }

}
