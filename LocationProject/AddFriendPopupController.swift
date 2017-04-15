//
//  AddFriendPopupController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 11/04/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase

class AddFriendPopupController: UIViewController {
    
    @IBOutlet weak var popupBackground: UIView!
    @IBOutlet weak var emailTextfield: UITextField!
    let dbRef = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.popupBackground.layer.cornerRadius = 10
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePopup() {
        self.view.removeFromSuperview()
    }
    
    @IBAction func addFriend() {
        let email = self.emailTextfield.text!
        
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("users").queryOrdered(byChild: "userEmail").queryEqual(toValue: email)
        
        ref.observe(.value, with: { snapshot in 
            if(snapshot.value is NSNull) {
                print("User doesn't exist!")
            } else {
                print("Invitation sent!")
                
                for snap in snapshot.children {
                    let singleSnapshot = snap as! FIRDataSnapshot
                    ref.removeAllObservers()
                    
                    if let value = singleSnapshot.value as? [String: Any] {
                        let userId = value["userId"] as! String
                        
                        print(value)
                        
                        let currentUser = FIRAuth.auth()?.currentUser?.uid
                        print("Current User - \(currentUser)")
                        
                        
                        let data = [ currentUser! : "false"]
                        self.dbRef.child("users").child(userId).child("friends").childByAutoId().setValue(data)
                        
                    }
                    
                }
            }
            
        }) 
    }   
    
    
    
}
