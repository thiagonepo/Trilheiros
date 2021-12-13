//
//  ClusterView.swift
//  Trilheiros
//
//  Created by Gael on 04/12/21.
//

import UIKit
import MapKit

class ClusterView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
      willSet {
        markerTintColor = UIColor.systemRed
      }
    }
}
