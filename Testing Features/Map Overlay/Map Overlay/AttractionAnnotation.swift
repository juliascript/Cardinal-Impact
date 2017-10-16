//
//  AttractionAnnotation.swift
//  Map Overlay
//
//  Created by Miriam Hendler on 9/4/17.
//  Copyright © 2017 Miriam Hendler. All rights reserved.
//

import UIKit
import MapKit

enum AttractionType: Int {
    case misc = 0
    case ride
    case food
    case firstAid
    
    func image() -> UIImage {
        switch self {
        case .misc:
            return #imageLiteral(resourceName: "star")
        case .ride:
            return #imageLiteral(resourceName: "ride")
        case .food:
            return #imageLiteral(resourceName: "food")
        case .firstAid:
            return #imageLiteral(resourceName: "firstaid")
        }
    }
}

class AttractionAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var type: AttractionType
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, type: AttractionType) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.type = type
    }
}
