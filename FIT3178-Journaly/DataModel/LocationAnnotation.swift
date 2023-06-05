//
//  LocationAnnotation.swift
//  FIT3178-Journaly
//
//  Created by Liangdi Wang on 5/6/2023.
//

import UIKit
import MapKit

class LocationAnnotation: NSObject, MKAnnotation {

    // Properties
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    // Initialiser
    init(title: String?, subtitle: String?, lat: Double, long: Double) {
        self.title = title
        self.subtitle = subtitle
        coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
    }
    
}
