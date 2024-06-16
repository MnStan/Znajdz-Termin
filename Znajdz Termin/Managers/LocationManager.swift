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
    var voivodeship: String { get }
    
    func requestWhenInUseAuthorization()
}

class AppLocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
    static let shared: LocationManagerProtocol = AppLocationManager(locationManager: CLLocationManager())
    private var locationManager: CLLocationManager
    private let geocoder = CLGeocoder()
    
    var authorizationStatus: CLAuthorizationStatus {
        locationManager.authorizationStatus
    }
    
    var location: CLLocation? {
        locationManager.location
    }
    
    var voivodeship = "Nieznane"
    
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
  
    func getUserVoivodeship() async {
        if let location = locationManager.location {
            do {
                let placemark = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemark.first {
                    if let placemarkVoivodeship = placemark.administrativeArea {
                        voivodeship = placemarkVoivodeship
                        print(placemarkVoivodeship)
                    }
                }
            } catch {
                //TODO: Error handling for getting voivodeship
                print(error)
            }
        }
    }
    
    func updateUserVoivodeship() {
        
    }
    
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task {
            await getUserVoivodeship()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
        //TODO: Error when location fetch fail
        print(error)
    }
}
