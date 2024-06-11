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

extension CLLocationManager: LocationManagerProtocol {  }

class AppLocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
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
        super.init()
        self.locationManager.delegate = self
        setup()
    }
    
    private func setup() {
        switch locationManager.authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print("Location updated", locations.first)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        //TODO: Error when location fetch fail
        print(error)
    }
}
