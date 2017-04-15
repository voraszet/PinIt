//
//  EventsViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 14/02/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class EventsViewController: UIViewController {
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func showUserEvents() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: MyEventsTableController = storyboard.instantiateViewController(withIdentifier: "MyEventsTableController") as! MyEventsTableController
        
        
        // query here        
        
        
        //
        self.present(view, animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func showMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    @IBAction func addEvents() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: AddEventsViewController = storyboard.instantiateViewController(withIdentifier: "AddEventsViewController") as! AddEventsViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    
    
    
}
