



import UIKit
import Firebase

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/")
    let currentUser = FIRAuth.auth()?.currentUser?.uid
    
    @IBOutlet weak var tableView: UITableView!
    
    // USERS DICTIONARY HOLDING ALL DETAILS ABOUT USER
    var usersDictionary = [[String:String]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadFriends()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func loadMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    // LOAD ALL FRIENDS DETAILS ON TABLEVIEW
    func loadFriends(){
        var atleastone = false
        ref.child("users").child(self.currentUser!).child("friends").observe(.value, with: { snapshot in 
            self.usersDictionary.removeAll()
            
            for snap in snapshot.children {    
                let keyValueSnap = snap as! FIRDataSnapshot
                
                if let keyValue = keyValueSnap.value as? [String:Any] {
                    
                    let friendBooleanValue = keyValue.first!.value as? String
                    
                    if friendBooleanValue == "true" {
                        let userId = keyValue.first!.key as? String
                        atleastone = true
                        self.ref.child("users").child(userId!).observe(.value, with: { snapshot in 
                            let snap = snapshot as! FIRDataSnapshot
                            if let x = snap.value as? [String:Any]{
                                let userArray = ["userName" : x["userName"]!,
                                                 "userId": x["userId"]!
                                ]
                                
                                self.usersDictionary.append(userArray as! [String:String])
                                self.tableView.reloadData()
                                
                            }
                            
                        })
                    } 
                    if !atleastone{ 
                        self.usersDictionary.removeAll()
                        self.tableView.reloadData()
                    }
                    
                    
                } 
                atleastone = false
            }
            
        })
        
    }
    
    // OPEN ONE TO ONE USER CHAT
    func getSingleChatLog( userId : String ){
        let ref = FIRDatabase.database().reference(fromURL: "https://locationapp-85fdc.firebaseio.com/").child("users").queryOrdered(byChild: "userId").queryEqual(toValue: userId)
        
        ref.observe(.value, with: { snapshot in
            
            for snapshotValues in snapshot.children {
                let userSnap = snapshotValues as! FIRDataSnapshot
                
                if let x = userSnap.value as? [String:Any] {
                    self.transitionToSingleChatLog(userId: x["userId"]! as! String, userName: x["userName"]! as! String)
                }
            }
        })
    }
    
    // TRANSITION TO SINGLE CHAT LOG ( ONE TO ONE Converstation )
    func transitionToSingleChatLog(userId : String, userName : String){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let view: SingleChatViewController = storyboard.instantiateViewController(withIdentifier: "SingleChatViewController") as! SingleChatViewController
        
        view.userName = userName
        view.userId = userId
        
        self.present(view, animated: true, completion: nil) 
    }
    
    // ADD FRIENDS BUTTON
    @IBAction func addFriendAction() {
        
        let popForm = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddFriendPopupController") as! AddFriendPopupController
        self.addChildViewController(popForm)
        popForm.view.frame = self.view.frame
        self.view.addSubview(popForm.view)
        popForm.didMove(toParentViewController: self)
        
    }
    
    
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.usersDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        cell.textLabel?.text = self.usersDictionary[indexPath.row]["userName"]
        cell.detailTextLabel?.text = self.usersDictionary[indexPath.row]["userId"] 
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let userId = self.usersDictionary[indexPath.row]["userId"]!
        self.getSingleChatLog(userId : userId)
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
}
