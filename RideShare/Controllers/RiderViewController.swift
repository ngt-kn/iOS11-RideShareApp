//
//  RiderViewController.swift
//  RideShare
//
//  Created by Kenneth Nagata on 5/29/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import MapKit

class RiderViewController: UIViewController, CLLocationManagerDelegate{
    
    @IBOutlet weak var map: MKMapView!
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coordinates = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coordinates.latitude, longitude: coordinates.longitude)
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
    }
    
    @IBAction func callDriverButtonPressed(_ sender: UIButton) {
    }
    
}
