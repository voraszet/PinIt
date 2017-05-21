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
    @IBOutlet weak var passwordTextfield2: UITextField!
    
    
    @IBOutlet weak var registerOutlet: UIButton!
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var switcherButton: UIButton!
    
    var x:Bool = false
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
    
    @IBAction func switchForms(_ sender: Any) {
        
        if (!x){
            usernameTextfield.isHidden = true
            switcherButton.setTitle("Switch to Register", for: .normal)
            
            self.loginOutlet.isHidden = false
            //self.loginOutlet.isEnabled = false 
            self.registerOutlet.isHidden = true
            //self.registerOutlet.isEnabled = true
            self.passwordTextfield2.isHidden = true
            x = true
        }else {
            usernameTextfield.isHidden = false
            switcherButton.setTitle("Switch to Login", for: .normal)
            
            self.loginOutlet.isHidden = true
            //self.loginOutlet.isEnabled = true 
            self.registerOutlet.isHidden = false
            //self.registerOutlet.isEnabled = false
            self.passwordTextfield2.isHidden = false
            x = false
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginOutlet.isHidden = true
    }
    
    func login(){
        let email = emailTextfield.text
        let password = passwordTextfield.text
        
        
        FIRAuth.auth()?.signIn(withEmail: email!, password: password!){ (user, error) in
            if(error == nil){
                //  Push the MenuViewController
                self.transitionToMainPageWithUsername()
            }else{
                let alertBox = UIAlertController(title: "Warning!", message: "Invalid username or password!", preferredStyle: UIAlertControllerStyle.alert)
                alertBox.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(alertBox, animated: true, completion: nil)
            }
        }
    }
    
    func register(){
        // set UITextFields to local function variables
        let email = emailTextfield.text
        let password = passwordTextfield.text
        let username = usernameTextfield.text
        let password2 = passwordTextfield2.text

        // FIRAuth.auth() allows the the application to use functions
        // such as creating a new user, logging in, requesting a forgotten password, accesing user ID, etc
        if password == password2 {
            // use FIRAuth class createUser function and pass in the parameters (email, password)
            FIRAuth.auth()?.createUser(withEmail: email!.lowercased(), password: password!){ (user, error) in
                // checking if there is no error when creating a new user
                if(error == nil){
                    print("Sucesful ")
                    // upon succesful creation, set a reference of the database
                    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
                    // using the FIRAuth class to access currently logged in user ID
                    // this is extremely important feature when loading or saving user specific data
                    let currentUser = FIRAuth.auth()?.currentUser
                    let userId = currentUser?.uid
                    let userData = ["userId": userId!, "userEmail": email!.lowercased(), "userName" : username!]
                    // saving user id, email and username to a specified database referece
                    // creating a new or appending to an existing users table using child("users") function
                    // finally passing NSArray to setValue() function that stores data within database reference
                    ref.child("users").child(userId!).setValue(userData)
                    
                    // as the user is authenticated, additional user data is saved onto a database
                    // FIRAuth class signIn function is automatically called, that logs in an existing user to the system
                    FIRAuth.auth()?.signIn(withEmail: email!.lowercased(), password: password!){ (user, error) in
                        // check if user credentials matched
                        if(error == nil){
                            print("Yes")
                            
                            // show another view with username
                            self.transitionToMainPageWithUsername()
                        }else{
                            // display error of not being able to log in
                            let alertBox = UIAlertController(title: "Warning!", message: "Invalid username or password!", preferredStyle: UIAlertControllerStyle.alert)
                            alertBox.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                            self.present(alertBox, animated: true, completion: nil)
                        }
                    }
                    // error message when trying to register within the system  
                } else{
                    print("ERROR == \(error)")
                    let alertBox = UIAlertController(title: "Warning!", message: "Failed to register!", preferredStyle: UIAlertControllerStyle.alert)
                    alertBox.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(alertBox, animated: true, completion: nil)
                }
            }
        } else {
            let alertBox = UIAlertController(title: "Warning!", message: "Your passwords don't match!", preferredStyle: UIAlertControllerStyle.alert)
            alertBox.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertBox, animated: true, completion: nil)
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

