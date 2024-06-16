//
//  LocationManager.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/05/2024.
//

import Foundation
import MapKit
import Combine

protocol LocationManagerProtocol {
    var authorizationStatus: CLAuthorizationStatus { get }
    var location: CLLocation? { get }
    var voivodeship: String { get }
    var locationErrorPublished: PassthroughSubject<LocationError?, Never> { get }
    
    func requestWhenInUseAuthorization()
}

class AppLocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
    static let shared: LocationManagerProtocol = AppLocationManager(locationManager: CLLocationManager())
    private var locationManager: CLLocationManager
    private let geocoder = CLGeocoder()
    private let radius: CLLocationDistance = 100000 // 100 km
    private let numberOfPoints = 20
    @Published var nearLocations: [LocationData] = []
    let locationErrorPublished = PassthroughSubject<LocationError?, Never>()
    
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
    }
    
    func getUserVoivodeship() async {
        if let location = locationManager.location {
            do {
                let placemark = try await geocoder.reverseGeocodeLocation(location)
                if let placemark = placemark.first {
                    if let placemarkVoivodeship = placemark.administrativeArea {
                        voivodeship = placemarkVoivodeship
                    }
                }
            } catch {
                locationErrorPublished.send(LocationError.localizationUnknown)
            }
        }
    }

    func pointsOnCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance, numberOfPoints: Int) {
        var points: [LocationData] = []
        let earthRadius: CLLocationDistance = 6371000
        
        for i in 0..<numberOfPoints {
            let bearing = Double(i) * 360.0 / Double(numberOfPoints) * .pi / 180
            
            let lat1 = center.latitude * .pi / 180
            let lon1 = center.longitude * .pi / 180
            
            let lat2 = asin(sin(lat1) * cos(radius / earthRadius) + cos(lat1) * sin(radius / earthRadius) * cos(bearing))
            var lon2 = lon1 + atan2(sin(bearing) * sin(radius / earthRadius) * cos(lat1), cos(radius / earthRadius) - sin(lat1) * sin(lat2))
            
            lon2 = (lon2 + 3 * .pi).truncatingRemainder(dividingBy: 2 * .pi) - .pi
            
            let lat2Degrees = lat2 * 180 / .pi
            let lon2Degrees = lon2 * 180 / .pi
            
            points.append(LocationData(coordinate: CLLocationCoordinate2D(latitude: lat2Degrees, longitude: lon2Degrees)))
        }
        
        self.nearLocations = points
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
        if let clError = error as? CLError {
            switch clError.code {
            case .locationUnknown:
                locationErrorPublished.send(LocationError.localizationUnknown)
            case .denied:
                locationErrorPublished.send(LocationError.authorizationDenied)
            case .network:
                locationErrorPublished.send(LocationError.networkError)
            case .geocodeCanceled, .geocodeFoundNoResult, .geocodeFoundPartialResult:
                locationErrorPublished.send(LocationError.geocodeError)
            default:
                locationErrorPublished.send(LocationError.custom(error: clError))
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.requestLocation()
            locationErrorPublished.send(nil)
        case .denied, .restricted:
            locationErrorPublished.send(LocationError.authorizationDenied)
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        default:
            locationErrorPublished.send(LocationError.localizationUnknown)
        }
    }
}
