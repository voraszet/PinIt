




import UIKit
import Firebase
import MapKit

class MapViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    let locManager = CLLocationManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMap()
    }
    
    // MENU BUTTON
    @IBAction func loadMenu() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondView: MenuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as! MenuViewController
        
        self.present(secondView, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        
        self.displayMap(long: location.coordinate.longitude, lat: location.coordinate.latitude)
    }
    
    func displayMap(long:Double, lat:Double){
        let distanceSpan:CLLocationDegrees = 1500
        let currentLocation:CLLocationCoordinate2D = CLLocationCoordinate2DMake(lat, long)
        
        
        self.mapView.setRegion(MKCoordinateRegionMakeWithDistance(currentLocation, distanceSpan, distanceSpan), animated: true)
        
        //  display current location
        self.mapView.showsUserLocation = true
    }
    
    
    func loadMap(){
        locManager.delegate = self
        locManager.desiredAccuracy = kCLLocationAccuracyBest
        locManager.requestWhenInUseAuthorization()
        locManager.startUpdatingLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    

}

