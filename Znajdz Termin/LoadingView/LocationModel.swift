//
//  LocationModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 16/06/2024.
//

import Foundation
import CoreLocation

struct LocationData: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}
