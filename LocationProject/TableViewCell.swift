//
//  TableViewCell.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 13/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var acceptButtonOutlet: UIButton!
    @IBOutlet weak var declineButtonOutlet: UIButton!
    
    @IBAction func declineButton() {
    }
}
