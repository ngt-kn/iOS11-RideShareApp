//
//  AcceptRequestViewController.swift
//  RideShare
//
//  Created by Kenneth Nagata on 5/30/18.
//  Copyright © 2018 Kenneth Nagata. All rights reserved.
//

import UIKit
import MapKit

class AcceptRequestViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    
    var requestLocation = CLLocationCoordinate2D()
    var requestEmail = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let region = MKCoordinateRegion(center: requestLocation, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = requestLocation
        annotation.title = requestEmail
        mapView.addAnnotation(annotation)
    }

    @IBAction func acceptPressed(_ sender: UIButton) {
    }
    
    


}
