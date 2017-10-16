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
    var currentUserLocation: MKUserLocation?
    var fb = FirebaseHelper()
    var users: [User] = [] {
        didSet {
            print("There are \(users.count) users")
            mapView.removeAnnotations(mapView.annotations)
            
            for user in users {
                let location = CLLocationCoordinate2DMake(user.latitude, user.longitude)
                let pin = MKPointAnnotation()
                if user.type == StudentType.wizard.rawValue {
                    pin.subtitle = StudentType.wizard.rawValue
                } else if user.type == StudentType.newcomer.rawValue {
                    pin.subtitle = StudentType.newcomer.rawValue
                }
                pin.coordinate = location
                pin.title = user.name
                mapView.addAnnotation(pin)
                if user.type == "student" && user.state == "lost" {
                    //                    flash their icon
                    //                    animate large and small
                    print(user)
                    print("DA DADA DADADADA DA NOW WE'RE LOST")
                    
                }
            }
        }
    }
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    
    @IBAction func settingButtonPressed(_ sender: Any) {
        instantiateSettings()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        mapView.userTrackingMode = .follow
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
        print("current location button tapped")
        self.zoomToCenter(center: center)
    }
    
    @IBAction func lostButtonTapped(_ sender: Any) {
        print(#function)
        fb.updateUserValue(key: "state", value: "lost")
        let alert = UIAlertController(title: "Don't worry",
                          message: "Help is on the way!",
                          preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "OK", style: .default) { (action) in
            print("ok button pressed")
        }
        let cancelButton = UIAlertAction(title: "Nevermind", style: .destructive) { (action) in
            print("Cancel")
            self.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okButton)
        alert.addAction(cancelButton)
        self.present(alert, animated: true)
    }
        func instantiateSettings() {
            let storyboard = UIStoryboard(name: "temp", bundle: nil)
    
            let vc = storyboard.instantiateViewController(withIdentifier: "Settings") as! SettingsViewController
            vc.currentUser = self.currentUser
            self.present(vc, animated: true, completion: nil)
        }
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        if self.currentUserLocation == userLocation {
            return
        }
        print("user location changed: \(userLocation.coordinate)")
        self.currentUserLocation = userLocation
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
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "CustomAnnotation")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "CustomAnnotation")
        } else {
            annotationView?.annotation = annotation
        }
        
        if let type = annotation.subtitle {
            // have to check again because the type of annotation.subtitle is String??
            if let type = type {
                annotationView?.image = UIImage(named: type)
            } else {
                annotationView?.image = UIImage(named: "default")
            }
        } else {
            annotationView?.image = UIImage(named: "default")
        }
        
        
        
        annotationView?.canShowCallout = true
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
