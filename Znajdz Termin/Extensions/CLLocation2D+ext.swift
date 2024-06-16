//
//  CLLocation2D+ext.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 16/06/2024.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {
    func isEqual(to coordinate: CLLocationCoordinate2D, withTolerance tolerance: CLLocationDegrees = 0.001) -> Bool {
        let latEqual = abs(self.latitude - coordinate.latitude) <= tolerance
        let lonEqual = abs(self.longitude - coordinate.longitude) <= tolerance
        return latEqual && lonEqual
    }
}
