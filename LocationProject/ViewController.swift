//
//  ViewController.swift
//  LocationProject
//
//  Created by Adrijus Zelinskis on 07/02/2017.
//  Copyright © 2017 Adrijus Zelinskis. All rights reserved.
//

import UIKit
import Firebase


class ViewController: UIViewController {
    // TEXTFIELDS
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var usernameTextfield: UITextField!
    
    
    
    // BUTTONS
    @IBOutlet weak var registerBtn: UIButton!
    
    // LOGIN IBAction
    @IBAction func loginFunction(_ sender: AnyObject) {
        login()
    }
    // REGISTER IBAction 
    @IBAction func registerButton(_ sender: AnyObject) {
        register()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextfield.text = "Adrijus@gmail.com"
        passwordTextfield.text = "adrijus"
    }
    
    func login(){
        let email = emailTextfield.text
        let password = passwordTextfield.text
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!){ (user, error) in
            if(error == nil){
                //  Push the MenuViewController
                self.transitionToMainPageWithUsername()
            }else{
                print("Error logging in")
            }
        }
    }
    
    func register(){
        
        let email = emailTextfield.text
        let password = passwordTextfield.text
        let username = usernameTextfield.text

        
        FIRAuth.auth()?.createUser(withEmail: email!.lowercased(), password: password!){ (user, error) in
            if(error == nil){
                print("Sucesful ")
                let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
                let currentUser = FIRAuth.auth()?.currentUser
                let userId = currentUser?.uid
                let userData = ["userId": userId!, "userEmail": email!.lowercased(), "userName" : username!]
                
                ref.child("users").child(userId!).setValue(userData)
                
                
                FIRAuth.auth()?.signIn(withEmail: email!.lowercased(), password: password!){ (user, error) in
                    if(error == nil){
                        print("Yes")
                        
                        //  Push the MenuViewController
                        self.transitionToMainPageWithUsername()
                    }else{
                        print("Error logging in")
                    }
                }
                
            } else{
                print("ERROR == \(error)")
            }
        }
    }
    
    func transitionToMainPageWithUsername(){
        let userId = FIRAuth.auth()?.currentUser?.uid
        let userRef  = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("users").child(userId!)
        
        userRef.observeSingleEvent(of: .value, with: { snapshot in 
            
            if snapshot.value is NSNull {
                print("the snapshot is empty")
            } else {
                if let snapValues = snapshot.value as? [String: Any]{
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let view: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
                    
                    view.usernameString = (snapValues["userName"]! as? String)!
                    
                    self.present(view, animated: true, completion: nil)
                }
                
            }
        })
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

