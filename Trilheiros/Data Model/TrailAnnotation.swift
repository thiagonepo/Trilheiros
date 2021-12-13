//
//  TrailAnnotation.swift
//  Trilheiros
//
//  Created by Gael on 04/12/21.
//

import UIKit
import MapKit

class TrailAnnotation: NSObject {
    let name: String
    let difficulty: String
    let location: CLLocation
    
    init(latitude: Double, longitude: Double, name: String, difficulty: String) {
        location = CLLocation(latitude: latitude, longitude: longitude)
        self.name = name
        self.difficulty = difficulty
    }
}
extension TrailAnnotation: MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        get {
            return location.coordinate
        }
    }
    
    var title: String? {
        get {
            return name
        }
    }
    
    var subtitle: String? {
        return difficulty
    }
    
}
