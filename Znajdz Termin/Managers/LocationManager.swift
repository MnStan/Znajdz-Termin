//
//  LocationManager.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/05/2024.
//

import Foundation
import MapKit

protocol LocationManagerProtocol {
    var authorizationStatus: CLAuthorizationStatus { get }
    var location: CLLocation? { get }
    
    func requestWhenInUseAuthorization()
}

extension CLLocationManager: LocationManagerProtocol { }

class AppLocationManager: LocationManagerProtocol {
    static let shared: LocationManagerProtocol = AppLocationManager(locationManager: CLLocationManager())
    private var locationManager: CLLocationManager
    
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    var location: CLLocation? {
        locationManager.location
    }
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
}
