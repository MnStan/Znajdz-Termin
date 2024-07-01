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
    var locationWorkDone: PassthroughSubject<Bool, Never> { get }
    
    func requestWhenInUseAuthorization()
}

class AppLocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate {
    static let shared: LocationManagerProtocol = AppLocationManager(locationManager: CLLocationManager())
    private var locationManager: CLLocationManager
    private let geocoder = CLGeocoder()
    private let radius: CLLocationDistance = 100000 // 100 km
    #warning("Changed numberOfPoints for testing purposes")
    private let numberOfPoints = 2
    var nearVoivodeships: [String] = []
    @Published var nearLocations: [LocationData] = []
    let locationErrorPublished = PassthroughSubject<LocationError?, Never>()
    var locationWorkDone = PassthroughSubject<Bool, Never>()
    
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
    
    func getPointVoivodeship(for point: CLLocation) async -> String? {
        do {
            let placemark = try await geocoder.reverseGeocodeLocation(point)
            if let placemark = placemark.first {
                if placemark.country == "Polska" {
                    if let voivodeship = placemark.administrativeArea {
                        return voivodeship
                    }
                }
            }
        } catch {
            locationErrorPublished.send(LocationError.geocodeError)
            locationWorkDone.send(false)
        }
        
        return nil
    }
    
    func getNearPointsVoivodeships(for points: [LocationData]) async {
        var pointsVoivodeships: [String] = []
        
        for point in points {
            if let voivodeship = await getPointVoivodeship(for: CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)) {
                pointsVoivodeships.append(voivodeship)
            }
        }
        
        nearVoivodeships = Array(Set(pointsVoivodeships))
        locationWorkDone.send(true)
    }
    
    func getLocationAgain() {
        locationManager.stopUpdatingLocation()
        locationManager.startUpdatingLocation()
    }
    
    func requestWhenInUseAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func clearData() {
        locationErrorPublished.send(nil)
        locationWorkDone.send(false)
        nearLocations.removeAll()
        nearVoivodeships.removeAll()
        voivodeship = ""
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        if newLocation == location { return }
        Task {
            await getUserVoivodeship()
            if let userLocation = location {
                pointsOnCircle(center: userLocation.coordinate, radius: radius, numberOfPoints: numberOfPoints)
                await getNearPointsVoivodeships(for: nearLocations)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: any Error) {
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
