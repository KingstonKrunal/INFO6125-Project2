//
//  AddEventViewController.swift
//  INFO6125-Project2
//
//  Created by Krunal Shah on 2022-04-16.
//

import UIKit
import LocationPicker
import MapKit
import FirebaseAuth
import FirebaseFirestore

class AddEventViewController: UIViewController {
    
    @IBOutlet weak var eventNameTF: UITextField!
    @IBOutlet weak var eventDateDP: UIDatePicker!
    @IBOutlet weak var eventDescTV: UITextView!
    
    var address: String?
    var coordinate: CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func selectLocation(_ sender: UIButton) {
        let locationPicker = LocationPickerViewController()
        
        locationPicker.showCurrentLocationButton = true
        locationPicker.currentLocationButtonBackground = .blue

        locationPicker.mapType = .standard
        locationPicker.useCurrentLocationAsHint = true

        locationPicker.searchBarPlaceholder = "Search places"
        locationPicker.searchHistoryLabel = "Previously searched"

        locationPicker.resultRegionDistance = 500

        locationPicker.completion = { location in
            self.coordinate = location?.coordinate
            self.address = location?.address
        }

        locationPicker.modalPresentationStyle = .fullScreen

        self.navigationController?.pushViewController(locationPicker, animated: true)
    }
    
    @IBAction func addEvent(_ sender: Any) {
        if let address = address, let coordinate = coordinate, let eventName = eventNameTF.text, let eventDesc = eventDescTV.text, let uid = Auth.auth().currentUser?.uid {
            let eventDate = eventDateDP.date
            
            let db = Firestore.firestore()
            db.collection("events").addDocument(data: [
                "added_by": uid,
                "name": eventName,
                "address": address,
                "latitude": coordinate.latitude,
                "longitude": coordinate.longitude,
                "date": eventDate,
                "description": eventDesc
            ]) { err in
                if let err = err {
                    print("Error adding document: \(err)")
                    self.errorAlert(error: "Error occured while registering event")
                } else {
                    self.gotoMapVC()
                }
            }
        }
    }
    
    func gotoMapVC() {
        let nextViewController = self.storyboard?.instantiateViewController(withIdentifier: "mapViewController") as! MapViewController
        nextViewController.modalPresentationStyle = .fullScreen
        self.present(nextViewController, animated: true)
    }
    
    func errorAlert(error: String) {
        let alert = UIAlertController(title: "Event registration Failed!", message: error, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
