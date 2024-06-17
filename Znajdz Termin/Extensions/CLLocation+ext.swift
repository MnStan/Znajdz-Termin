//
//  CLLocation+ext.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 16/06/2024.
//

import Foundation
import CoreLocation

extension CLLocation {
    func isEqual(to location: CLLocation, withTolerance tolerance: CLLocationDegrees = 0.001) -> Bool {
        return abs(self.coordinate.latitude - location.coordinate.latitude) <= tolerance &&
               abs(self.coordinate.longitude - location.coordinate.longitude) <= tolerance
    }
}
