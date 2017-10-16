//
//  MapViewController.swift
//  Cardinal-Wizards
//
//  Created by Julia Geist on 10/14/17.
//  Copyright © 2017 Julia Geist. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/*
 TODO: - add annotations to map on setting of the users array
     - add custom image for each user - depending on wizard or newcomer 
 
 */

class MapViewController: UIViewController, MKMapViewDelegate {
    
    var locationManager = CLLocationManager()
    var currentUser: User?
    var fb = FirebaseHelper()
    var users: [User] = [] {
        didSet {
            print("There are \(users.count) users")
            
            for user in users {
                print(user)
                let location = CLLocationCoordinate2DMake(user.latitude, user.longitude)
                let pin = MKPointAnnotation()
                pin.coordinate = location
                pin.title = user.name
                mapView.addAnnotation(pin)
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        fb.retrieveUsers(vc: self)
        locationManager.requestWhenInUseAuthorization()
        mapView.showsUserLocation = true
        if #available(iOS 9.0, *) {
            mapView.showsScale = true
        }
        if #available(iOS 9.0, *) {
            mapView.showsCompass = true
        }
    }

    @IBAction func currentLocationButtonTapped(_ sender: Any) {
        guard let center = locationManager.location?.coordinate else {
            return
        }
        self.zoomToCenter(center: center)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        mapView.setCenter(userLocation.coordinate, animated: true)
        fb.updateUserValue(key: "longitude", value: "\(userLocation.coordinate.longitude)")
        fb.updateUserValue(key: "latitude", value: "\(userLocation.coordinate.latitude)")
        self.zoomToCenter(center: userLocation.coordinate)
    }
    
    func zoomToCenter(center: CLLocationCoordinate2D) {
        let span = MKCoordinateSpan(latitudeDelta: 0.0075, longitudeDelta: 0.0075)
        let region = MKCoordinateRegion(center: center, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print(#function)
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print(#function)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
