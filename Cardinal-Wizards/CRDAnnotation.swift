//
//  CRDAnnotation.swift
//  Cardinal-Wizards
//
//  Created by Julia Geist on 10/27/17.
//  Copyright © 2017 Julia Geist. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class CRDAnnotation: NSObject, MKAnnotation {
    public var currentLocation: CLLocationCoordinate2D
    private var _title: String?
    private var subTitle: String?
    var direction: CLLocationDirection!
    var typeOfAnnotation: String!
    var user: User?
    
    init(coordinate: CLLocationCoordinate2D) {
        self.currentLocation = coordinate
        self._title = nil
        self.subTitle = nil
        self.user = nil
    }
    
    func getLocation() -> CLLocation {
        return CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    public var coordinate: CLLocationCoordinate2D {
        get {
            return self.currentLocation
        }
        set (newValue) {
            self.currentLocation = newValue
        }
    }
    
    public var title: String? {
        get {
            return _title
        }
        set (newValue) {
            self._title = newValue
        }
    }
    
    public var subtitle: String? {
        get {
            return subTitle
        }
        set (newValue) {
            self.subTitle = newValue
        }
    }
}
