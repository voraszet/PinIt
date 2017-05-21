

import UIKit
import Firebase

class AddEventsViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var eventNameTextfield: UITextField!
    @IBOutlet weak var eventDescriptionTextarea: UITextView!
    
    @IBOutlet weak var address1Textfield: UITextField!
    @IBOutlet weak var address2Textfield: UITextField!
    @IBOutlet weak var cityTextfield: UITextField!
    @IBOutlet weak var postcodeTextfield: UITextField!
    
    let tf = UITextField()
    
    
    override func viewDidLoad() {
        
        self.eventNameTextfield.delegate = self
        self.address1Textfield.delegate = self
        self.address2Textfield.delegate = self
        self.cityTextfield.delegate = self
        self.postcodeTextfield.delegate = self
        self.eventDescriptionTextarea.delegate = self
        
        //self.eventDescriptionTextarea.delegate = self as! UITextViewDelegate
        
        super.viewDidLoad()
        
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        //NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let UItap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(dismissKeyboard))
        
        view.addGestureRecognizer(UItap)
        
        setDatePickerColor()
        
        self.eventNameTextfield.tag = 1
       // self.eventDescriptionTextarea.tag = 2
        
        self.address1Textfield.tag = 3
        self.address2Textfield.tag = 4
        self.cityTextfield.tag = 5
        self.postcodeTextfield.tag = 6        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
        
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        NotificationCenter.default.removeObserver(self)

        
        if ((textField.tag == 3) || (textField.tag == 4) || (textField.tag ==  5) || (textField.tag == 6)) {
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            
            
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
            
        }else{
            NotificationCenter.default.removeObserver(self)
        }
       
        
    }
    
    
    func keyboardShow(notification: NSNotification){
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //self.view.frame.origin.y -= keyboardHeight
            self.view.window?.frame.origin.y = -1 * keyboardHeight
        }
        
        
    }
    
    func keyboardHide(notification: NSNotification){
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            //self.view.frame.origin.y += keyboardHeight
            
            self.view.window?.frame.origin.y += keyboardHeight
        }   
    }
    
    @IBAction func loadMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        self.present(secondView, animated: true, completion: nil)
    }
    
    func setDatePickerColor(){
        datePicker.setValue(UIColor.white, forKey: "textColor")
    }
    
    @IBAction func addEvent() {
        
        if(self.eventNameTextfield.text == "" || self.eventDescriptionTextarea.text == "" || self.address1Textfield.text == "" || self.address2Textfield.text == "" || self.cityTextfield.text == "" || self.postcodeTextfield.text == "")
        {
            let alertBox = UIAlertController(title: "Warning!", message: "You must complete all fields!", preferredStyle: UIAlertControllerStyle.alert)
            alertBox.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(alertBox, animated: true, completion: nil)
        } 
        else 
        {
            let date = datePicker.date
            let eventName = eventNameTextfield.text
            let eventDescription = eventDescriptionTextarea.text
            let address1 = address1Textfield.text
            let address2 = address2Textfield.text
            let city = cityTextfield.text
            let postcode = postcodeTextfield.text
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd/MM/yy"
            
            let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
            let userId = FIRAuth.auth()?.currentUser?.uid
            
            let userRef = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("users").child(userId!)
            
            userRef.observeSingleEvent(of: .value, with: { snapshot in 
                
                if snapshot.value is NSNull{
                    print("empty")
                } else {
                    let value = snapshot.value as?  NSDictionary
                    let username = value?["userName"] as? String ?? ""
                    let eventId = ref.child("events").childByAutoId().key
                    
                    
                    let data = ["userName": username,
                                "userId": userId!,
                                "eventName": eventName!,
                                "eventDescription": eventDescription!,
                                "eventDate": dateFormatter.string(from: date),
                                "eventAddress1": address1!,
                                "eventAddress2": address2!,
                                "eventCity": city!,
                                "eventPostcode": postcode!,
                                "eventId": eventId
                    ]
                    
                    ref.child("events").child(eventId).setValue(data)
                    
                    //
                    //let messageData = ["messageId": messageId1, "userName":username, "message": message!]
                    //self.ref.child("messages").child(messageId1).childByAutoId().setValue(messageData)
                    ref.child("event_messages").child(eventId).childByAutoId().setValue([""])
                    
                }
            })
            
            // SAVE EVENT ID 

            let alertBox = UIAlertController(title: "Note!", message: "You have added an event!", preferredStyle: UIAlertControllerStyle.alert)
            alertBox.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                self.loadEventsView()
            }))
            self.present(alertBox, animated: true, completion: nil)
         }
    }
    
    func loadEventsView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: EventsViewController = storyboard.instantiateViewController(withIdentifier: "EventsViewController") as! EventsViewController
        self.present(view, animated: true, completion: nil)
    }
    
    @IBAction func inviteFriends() {
        print("friend inv")
    }
    
    
    
    
    
    
    
    
}
