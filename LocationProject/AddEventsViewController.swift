

import UIKit
import Firebase

class AddEventsViewController: UIViewController {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var eventNameTextfield: UITextField!
    @IBOutlet weak var eventDescriptionTextarea: UITextView!
    
    @IBOutlet weak var address1Textfield: UITextField!
    @IBOutlet weak var address2Textfield: UITextField!
    @IBOutlet weak var cityTextfield: UITextField!
    @IBOutlet weak var postcodeTextfield: UITextField!
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDatePickerColor()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
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
                    let data = ["userName": username,
                                "userId": userId!,
                                "eventName": eventName!,
                                "eventDescription": eventDescription!,
                                "eventDate": dateFormatter.string(from: date),
                                "eventAddress1": address1!,
                                "eventAddress2": address2!,
                                "eventCity": city!,
                                "eventPostcode": postcode!
                    ]
                    
                    ref.child("events").childByAutoId().setValue(data)
                }
            })
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
