//
//  DetailsController.swift
//  Trilheiros
//
//  Created by Gael on 10/10/21.
//

import Foundation
import MapKit
import CoreLocation

class DetailsController {
        
    func addTrailAnnotation(trailLat: String?, trailLon: String?, trailName: String?, mapView: MKMapView) {
        
        guard let latitude = CLLocationDegrees(trailLat ?? ""), let longitude = CLLocationDegrees(trailLon ?? "") else { return }

        let location = CLLocation(latitude: latitude, longitude: longitude)
        
        let trailLocations = MKPointAnnotation()
        trailLocations.title = trailName ?? ""
        trailLocations.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        mapView.addAnnotation(trailLocations)
        mapView.centerToLocation(location, regionRadius: 5000)
    }
    

}
