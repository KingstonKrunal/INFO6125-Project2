//
//  ListEventsViewController.swift
//  INFO6125-Project2
//
//  Created by Krunal Shah on 2022-04-17.
//

import UIKit
import FirebaseFirestore
import CoreLocation

class Event {
    let name: String
    let address: String
    let date: String
    let latitude: Double
    let longitude: Double
    
    internal init(name: String, address: String, date: String, latitude: Double, longitude: Double) {
        self.name = name
        self.address = address
        self.date = date
        self.latitude = latitude
        self.longitude = longitude
    }
}

class ListEventsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var eventsTV: UITableView!
    var events = [Event]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        eventsTV.delegate = self
        eventsTV.dataSource = self
        
        fetchEvents()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return events.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell") as! ListEventCellTableViewCell
        
        let event = events[indexPath.row]
        cell.fillCell(name: event.name, address: event.address, date: event.date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let event = events[indexPath.row]
        if let presenter = presentingViewController as? MapViewController {
            presenter.selectedEventLocation = CLLocation(latitude: event.latitude, longitude: event.longitude)
            presenter.zoomIntoEventLocation()
        }
        self.dismiss(animated: true)
        
    }
    
    func errorAlert(title: String, error: String) {
        let alert = UIAlertController(title: title, message: error, preferredStyle: UIAlertController.Style.alert)

        alert.addAction(UIAlertAction(title: "Ok",
                                      style: UIAlertAction.Style.default,
                                      handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchEvents() {
        let db = Firestore.firestore()
        db.collection("events").whereField("date", isGreaterThan: NSDate())
            .addSnapshotListener { documentSnapshot, err in
                if let err = err {
                    print("Error getting documents: \(err)")
                    self.errorAlert(title: "Error plotting events", error: err.localizedDescription)
                } else {
                    self.events.removeAll()
                    
                    for document in documentSnapshot!.documents {
                        let map = document.data()
                        let date = map["date"] as? NSDate ?? NSDate()
                        
                        self.events.append(Event(
                            name: map["name"] as! String,
                            address: map["address"] as! String,
                            date: date.description,
                            latitude: map["latitude"] as! Double,
                            longitude: map["longitude"] as! Double
                        ))
                    }
                    
                    self.eventsTV.reloadData()
                }
        }
    }
    
}
