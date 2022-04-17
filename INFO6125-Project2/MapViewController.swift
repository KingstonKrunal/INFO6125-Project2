//
//  MapViewController.swift
//  INFO6125-Project2
//
//  Created by Krunal Shah on 2022-04-12.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var menuButton: UIButton!
    @IBOutlet private var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var currentLocationStr = "Current location"
    var currentLocation: CLLocation?
    var selectedEventLocation: CLLocation?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.delegate = self
        
        trackCurrentLocation()
        addEventsToMap()
    }
    
    @IBAction func myLocation(_ sender: UIButton) {
        zoomIntoCurrectLocation()
    }
    
    @IBAction func addEvent(_ sender: UIButton) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "addEventNVC") as! UINavigationController
        self.present(nextViewController, animated: true)
    }
    
    @IBAction func showActionSheet(_ sender: UIButton) {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Show Profile",
                                      style: .default) { _ in
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
            self.present(nextViewController, animated: true)
        })
        
        alert.addAction(UIAlertAction(title: "Show Events",
                                      style: .default) { _ in
            let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "eventsVC") as! ListEventsViewController
            self.present(nextViewController, animated: true)
        })

        alert.addAction(UIAlertAction(title: "Logout",
                                      style: .destructive) { _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                
                // Go to login view
                let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LogInViewController
                nextViewController.modalPresentationStyle = .fullScreen
                self.present(nextViewController, animated: true)
            } catch let signOutError as NSError {
                self.errorAlert(title: "Error signing out", error: signOutError.localizedDescription)
            }
        })

        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel))

        self.present(alert, animated: true)
    }
    
    func errorAlert(title: String, error: String) {
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "MyMarker")
        
        if annotation.title == currentLocationStr {
//            annotationView.markerTintColor = UIColor.magenta
            annotationView.glyphImage = UIImage(named: "pin")
        } else {
            annotationView.markerTintColor = UIColor(red: (69.0/255), green: (95.0/255), blue: (170.0/255), alpha: 1.0)
            annotationView.glyphImage = UIImage(named: "library")
        }
        
        return annotationView
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0] as CLLocation

        let location2D = CLLocationCoordinate2D(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)

        mapView.findClosestLocation(currentLocation!) { address in
            self.mapView.addAnnotation(
                MapPoint(title: self.currentLocationStr,
                         locationName: address,
                         discipline: "Current Location",
                         coordinate: location2D))
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error - locationManager: \(error.localizedDescription)")
    }

    func trackCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()

        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func zoomIntoCurrectLocation() {
        if currentLocation != nil {
            mapView.centerToLocation(
                currentLocation!,
                regionRadius: 600
            )
        }
    }
    
    func zoomIntoEventLocation() {
        if selectedEventLocation != nil {
            mapView.centerToLocation(
                selectedEventLocation!,
                regionRadius: 500
            )
        }
    }
    
    func addEventsToMap() {
        let db = Firestore.firestore()
        db.collection("events").whereField("date", isGreaterThan: NSDate())
            .getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.errorAlert(title: "Erroe plotting events", error: err.localizedDescription)
                } else {
                    for document in querySnapshot!.documents {
                        self.mapView.addAnnotation(MapPoint(
                            title: document.get("name") as? String ?? "",
                            locationName: document.get("address") as? String ?? "",
                            discipline: document.get("name") as? String ?? "",
                            coordinate: CLLocationCoordinate2D(
                                latitude: document.get("latitude") as? Double ?? 0,
                                longitude: document.get("longitude")  as? Double ?? 0)))
                    }
                }
        }
    }
}


extension MKMapView {
    func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 500) {
        let coordinateRegion = MKCoordinateRegion(
              center: location.coordinate,
              latitudinalMeters: regionRadius,
              longitudinalMeters: regionRadius)
        setRegion(coordinateRegion, animated: true)
    }
    
    func findClosestLocation(_ location: CLLocation, complition: @escaping (String) -> ()){
        let geoCoder = CLGeocoder()

        geoCoder.reverseGeocodeLocation(location) {
            (placemarks, error) -> Void in

            if error == nil {
                if placemarks!.count > 0 {
                    let placemark = placemarks?[0]
                    let address = "\(placemark?.subThoroughfare ?? ""), \(placemark?.thoroughfare ?? ""), \(placemark?.locality ?? ""), \(placemark?.subLocality ?? ""), \(placemark?.administrativeArea ?? ""), \(placemark?.postalCode ?? ""), \(placemark?.country ?? "")"
                    complition(address)
                }
            }
        }
    }
}
