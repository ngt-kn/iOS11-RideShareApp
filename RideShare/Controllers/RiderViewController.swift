//
//  RiderViewController.swift
//  RideShare
//
//  Created by Kenneth Nagata on 5/29/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth


class RiderViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callDriverButton: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var driverHasBeenCalled = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        if let email = Auth.auth().currentUser?.email {
            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapShot) in
                self.driverHasBeenCalled = true
                self.callDriverButton.setTitle("Cancel Request", for: .normal)
                Database.database().reference().child("RideRequests").removeAllObservers()
                
            } 
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinates = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                userLocation = center
            let region = MKCoordinateRegion (center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            
            map.setRegion(region, animated: true)
            map.removeAnnotations(map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "Your Location"
            map.addAnnotation(annotation)
        }
    }

    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callDriverButtonPressed(_ sender: UIButton) {
        if let email = Auth.auth().currentUser?.email {
            
            if driverHasBeenCalled{
                driverHasBeenCalled = false
                callDriverButton.setTitle("Call Driver", for: .normal)

                Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snapShot) in
                    snapShot.ref.removeValue()
                    
                    Database.database().reference().child("RideRequests").removeAllObservers()
                }
            } else {
                driverHasBeenCalled = true
                callDriverButton.setTitle("Cancel Ride", for: .normal)

                let rideRequestDictionary : [String:Any] = ["email":email,"lat":userLocation.latitude,"lon":userLocation.longitude]
                Database.database().reference().child("RideRequests").childByAutoId().setValue(rideRequestDictionary)
            }
        }
    }
    
}
