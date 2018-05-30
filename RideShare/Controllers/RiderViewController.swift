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
    var driverLocation = CLLocationCoordinate2D()
    var driverOnTheWay = false
    
    
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
                
                if let rideRequestDictionary = snapShot.value as? [String:AnyObject] {
                    if let driverLat = rideRequestDictionary["driverLat"] as? Double,
                        let driverLon = rideRequestDictionary["driverLon"] as? Double {
                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                        self.driverOnTheWay = true
                        self.displayDriverAndRider()
                        
                        if let email = Auth.auth().currentUser?.email {
                            Database.database().reference().child("RideRequests").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snapshot) in
                                if let rideRequestDictionary = snapshot.value as? [String:AnyObject] {
                                    if let driverLat = rideRequestDictionary["driverLat"] as? Double,
                                        let driverLon = rideRequestDictionary["driverLon"] as? Double {
                                        self.driverLocation = CLLocationCoordinate2D(latitude: driverLat, longitude: driverLon)
                                        self.driverOnTheWay = true
                                        self.displayDriverAndRider()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func displayDriverAndRider() {
        let driverCLLocation = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        
        let distance = driverCLLocation.distance(from: riderCLLocation) / 1000
        let roundedDistance = round(distance * 100) / 100
        
        callDriverButton.setTitle("Your driver is \(roundedDistance) km away!", for: .normal)
        
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude) * 2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude) * 2 + 0.005
        let region = MKCoordinateRegion(center: userLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.coordinate = userLocation
        riderAnnotation.title = "Your location"
        map.addAnnotation(riderAnnotation)
        
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.coordinate = driverLocation
        driverAnnotation.title = "Driver location"
        map.addAnnotation(driverAnnotation)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinates = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
                userLocation = center

            if driverHasBeenCalled {
                displayDriverAndRider()
            } else {
                let region = MKCoordinateRegion (center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                
                map.setRegion(region, animated: true)
                map.removeAnnotations(map.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "Your Location"
                map.addAnnotation(annotation)
                
            }
        }
    }

    @IBAction func logoutButtonPressed(_ sender: UIBarButtonItem) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callDriverButtonPressed(_ sender: UIButton) {
        if !driverOnTheWay{
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
    
}
