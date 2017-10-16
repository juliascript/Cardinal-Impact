//
//  ParkMapOverlay.swift
//  Map Overlay
//
//  Created by Miriam Hendler on 9/4/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import MapKit

class ParkMapOverlay: NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D
    var boundingMapRect: MKMapRect
    
    init(park: Park) {
        boundingMapRect = park.overlayBoundingMapRect
        coordinate = park.midCoordinate
    }
}
