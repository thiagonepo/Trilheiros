//
//  TrailView.swift
//  Trilheiros
//
//  Created by Gael on 04/12/21.
//

import Foundation
import UIKit
import MapKit

class TrailView: MKMarkerAnnotationView {
    override var annotation: MKAnnotation? {
        willSet {
            if let placeAnnotation = newValue as? TrailAnnotation {
                glyphImage = #imageLiteral(resourceName: "Intermediate")
                clusteringIdentifier = "cluster"
                markerTintColor = UIColor.systemTeal
                canShowCallout = true
                let btn = UIButton(type: .detailDisclosure)
                rightCalloutAccessoryView = btn
            }
        }
    }
    
}
