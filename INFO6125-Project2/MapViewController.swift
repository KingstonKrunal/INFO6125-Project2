//
//  MapViewController.swift
//  INFO6125-Project2
//
//  Created by Krunal Shah on 2022-04-16.
//

import UIKit
import FirebaseAuth
import MapKit


class MapViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet private var mapView: MKMapView!
    
    var locationManager: CLLocationManager!
    var currentLocationStr = "Current location"
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let artwork = MapPoint(
          title: "King David Kalakaua",
          locationName: "Waikiki Gateway Park",
          discipline: "Event",
          coordinate: CLLocationCoordinate2D(latitude: 21.283921, longitude: -157.831661))
        mapView.addAnnotation(artwork)
        
        trackCurrentLocation()
    }
    
    @IBAction func myLocation(_ sender: UIButton) {
        zoomIntoCurrectLocation()
    }
    
    @IBAction func addEvent(_ sender: UIButton) {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "addEventNVC") as! UINavigationController
//        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true)
    }
    
    @IBAction func showActionSheet(_ sender: UIButton) {
        let alert = UIAlertController(title: nil,
                                      message: nil,
                                      preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title: "Show Profile",
                                      style: .default) { _ in
            // onAction1()
        })
        
        alert.addAction(UIAlertAction(title: "Show Events",
                                      style: .default) { _ in
            // onAction1()
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
                                      style: .cancel) { _ in
            // onCancel
        })

        self.present(alert, animated: true)
    }
    
    func errorAlert(title: String, error: String) {
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let mUserLocation:CLLocation = locations[0] as CLLocation

        currentLocation = CLLocationCoordinate2D(latitude: mUserLocation.coordinate.latitude, longitude: mUserLocation.coordinate.longitude)

        mapView.findClosestLocation(mUserLocation) { address in
            self.mapView.addAnnotation(
                MapPoint(title: "Current Location",
                         locationName: address,
                         discipline: "Current Location",
                         coordinate: self.currentLocation!))
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
                CLLocation(latitude: currentLocation!.latitude, longitude: currentLocation!.longitude),
                regionRadius: 1000
            )
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
