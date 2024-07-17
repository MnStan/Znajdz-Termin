//
//  LocationManager.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/05/2024.
//

import Foundation
import MapKit
import Combine

protocol LocationManagerProtocol: AnyObject {
    var authorizationStatus: CLAuthorizationStatus { get }
    var location: CLLocation? { get }
    var voivodeship: String { get }
    var locationErrorPublished: PassthroughSubject<LocationError?, Never> { get }
    var locationWorkDone: PassthroughSubject<Bool, Never> { get }
    var nearVoivodeships: [String] { get set }
    
    func requestWhenInUseAuthorization()
    func calculateDistanceFromPoint(to location: CLLocation) -> CLLocationDistance?
    func findCoordinatesOfCityName(name: String) async throws -> CLLocation?
}

class AppLocationManager: NSObject, LocationManagerProtocol, CLLocationManagerDelegate, ObservableObject {
    private var locationManager: CLLocationManager
    private let geocoder = CLGeocoder()
    private let radius: CLLocationDistance = 100000 // 100 km
#warning("Changed numberOfPoints for testing purposes")
    private let numberOfPoints = 15
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
    
    private let rateLimiter: LocationRateLimiter
    
    init(locationManager: CLLocationManager = CLLocationManager(), rateLimiter: LocationRateLimiter = LocationRateLimiter()) {
        self.locationManager = locationManager
        self.rateLimiter = rateLimiter
        super.init()
        self.locationManager.delegate = self
    }
    
    func getUserVoivodeship() async {
        if let location = locationManager.location {
            do {
                await rateLimiter.limitRequests()
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
    
    func calculatePointsOnCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance, numberOfPoints: Int) async -> [LocationData] {
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
        return points
        
    }
    
    func pointsOnCircle(center: CLLocationCoordinate2D, radius: CLLocationDistance, numberOfPoints: Int) async {
        let points = await calculatePointsOnCircle(center: center, radius: radius, numberOfPoints: numberOfPoints)
        
        await MainActor.run {
            nearLocations = points
        }
    }
    
    func getPointVoivodeship(for point: CLLocation) async -> String? {
        do {
            await rateLimiter.limitRequests()
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
        var pointsVoivodeships: Set<String> = []
        
        await withTaskGroup(of: String?.self) { group in
            for point in points {
                group.addTask {
                    let location = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
                    return await self.getPointVoivodeship(for: location)
                }
                
                for await result in group {
                    if let voivodeship = result {
                        if voivodeship != self.voivodeship {
                            pointsVoivodeships.insert(voivodeship)
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            self.nearVoivodeships = Array(pointsVoivodeships)
            self.locationWorkDone.send(true)
        }
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
                await pointsOnCircle(center: userLocation.coordinate, radius: radius, numberOfPoints: numberOfPoints)
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
    
    func findCoordinatesOfCityName(name: String) async throws -> CLLocation? {
        do {
            await rateLimiter.limitRequests()
            
            try await Task.sleep(nanoseconds: 250_000)
            
            try Task.checkCancellation()
            
            let place = try await geocoder.geocodeAddressString(name)
            
            if let firstPlace = place.first {
                return firstPlace.location
            }
        } catch {
            throw error
        }
        
        return nil
    }
    
    func calculateDistanceFromPoint(to location: CLLocation) -> CLLocationDistance? {
        return locationManager.location?.distance(from: location)
    }
    
    func resetQueue() {
        Task {
            await rateLimiter.reset()
        }
    }
}


actor LocationRateLimiter {
    private var requestTimestamps: [Date] = []
    private let maxRequestsPerMinute = 50
    private var requestQueue: [CheckedContinuation<Void, Never>] = []
    private var isProcessing = false
    
    init(requestTimestamps: [Date] = [], requestQueue: [CheckedContinuation<Void, Never>] = [], isProcessing: Bool = false) {
        self.requestTimestamps = requestTimestamps
        self.requestQueue = requestQueue
        self.isProcessing = isProcessing
    }
    
    
    func limitRequests() async {
        await withCheckedContinuation { continuation in
            requestQueue.append(continuation)
            
            if !isProcessing {
                processQueue()
            }
        }
    }
    
    private func processQueue() {
        guard !isProcessing, !requestQueue.isEmpty else { return }
        
        isProcessing = true
        Task {
            while !requestQueue.isEmpty {
                let now = Date()
                if requestTimestamps.count < maxRequestsPerMinute {
                    let continuation = requestQueue.removeFirst()
                    requestTimestamps.append(now)
                    continuation.resume()
                } else {
                    if let oldestTimestamp = requestTimestamps.last {
                        let waitTime = 60 - now.timeIntervalSince(oldestTimestamp)
                        if waitTime > 0 {
                            try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
                            requestTimestamps.removeFirst(50)
                        } else {
                            requestTimestamps.removeLast()
                        }
                    }
                }
            }
            isProcessing = false
                        requestTimestamps = requestTimestamps.filter { Date().timeIntervalSince($0) < 60 }
        }
    }
    
    func reset() {
        requestQueue.removeAll()
    }
}
