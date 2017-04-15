//
//  EventsViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 14/02/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class SingleEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var eventName:String?
    var eventDescription:String?
    var eventsArray: [String] = []
    
    var eventsDictionary: [String:Any] = [:]
    var eventsDicionaryCopy: [String] = [] 
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
            
        eventsDicionaryCopy = Array(self.eventsDictionary.keys) 
        
        eventNameLabel.text = self.eventName
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")

        tableView.delegate = self
        tableView.dataSource = self
        
        print("Events dictionary copy \(eventsDicionaryCopy)")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return eventsArray.count
        return eventsDicionaryCopy.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        let title = self.eventsDicionaryCopy[indexPath.row]
        let headings:[String] = ["Title",
                                "Location",
                                "2nd Line of Address",
                                "Date",
                                "Username",
                                "User ID",
                                "Event description",
                                "Postcode",
                                "1st Line of Address"]
        
        cell.textLabel?.text = headings[indexPath.row] as String?
        cell.detailTextLabel?.text = self.eventsDictionary[title] as! String?
        
        return cell
    }

    
    @IBAction func goToUserView() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: UserEventsController = storyboard.instantiateViewController(withIdentifier: "UserEventsController") as! UserEventsController        
        self.present(view, animated: true, completion: nil)
    }
    
    
    
    
    


    
}
