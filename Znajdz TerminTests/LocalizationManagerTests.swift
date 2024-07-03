//
//  LocalizationManagerTests.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 10/05/2024.
//

import XCTest
@testable import Znajdz_Termin
import CoreLocation
import Combine

class MockCLLocationManager: CLLocationManager {
    var mockAuthorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
    var mockLocation: CLLocation?
    
    override var authorizationStatus: CLAuthorizationStatus {
        mockAuthorizationStatus
    }
    
    override var location: CLLocation? {
        mockLocation
    }
    
    override var delegate: CLLocationManagerDelegate? {
        didSet {
            if let delegate = delegate, mockAuthorizationStatus != .notDetermined {
                delegate.locationManagerDidChangeAuthorization?(CLLocationManager())
            }
        }
    }
    
    func simulateLocationUpdate(location: CLLocation) {
        self.mockLocation = location
        delegate?.locationManager?(CLLocationManager(), didUpdateLocations: [location])
    }
}

final class LocalizationManagerTests: XCTestCase {
    var sut: AppLocationManager!
    var mockLocationManager: MockCLLocationManager!
    
    override func setUpWithError() throws {
        mockLocationManager = MockCLLocationManager()
        sut = AppLocationManager(locationManager: mockLocationManager)
    }
    
    override func tearDownWithError() throws {
        mockLocationManager = nil
        sut = nil
    }
    
    func testPerformanceExample() throws {
        self.measure {
        }
    }
    
    func testLocation() {
        let mockLocation = CLLocation(latitude: 50.123, longitude: -50.123)
        mockLocationManager.mockLocation = mockLocation
        XCTAssertEqual(sut.location, mockLocation)
    }
    
    func testSharedInstanceType() {
        let sharedInstance = AppLocationManager.shared
        XCTAssertTrue(sharedInstance is AppLocationManager)
    }
    
    func testAuthorizationStatus() {
        XCTAssertEqual(mockLocationManager.authorizationStatus, .authorizedWhenInUse)
    }
    
    func testGetVoivodeship() {
        let mockLocation = CLLocation(latitude: 50.061049, longitude: 19.937617) // Cracow coordinates -> Małopolskie
        let expectation = XCTestExpectation(description: "Geocoding completed")
        mockLocationManager.mockLocation = mockLocation
        
        Task {
            await sut.getUserVoivodeship()
            XCTAssertEqual(sut.voivodeship, "Małopolskie")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testGetVoivodeshipShouldFail() {
        let mockLocation = CLLocation(latitude: 50.061049, longitude: 19.937617) // Cracow coordinates -> Małopolskie
        let expectation = XCTestExpectation(description: "Geocoding completed")
        mockLocationManager.mockLocation = mockLocation
        
        Task {
            await sut.getUserVoivodeship()
            XCTAssertNotEqual(sut.voivodeship, "Podkarpackie")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testUpdatingLocation() {
        mockLocationManager.simulateLocationUpdate(location: CLLocation(latitude: 50.023604, longitude: 22.000681)) // Rzeszów coordinates
        
        if let location = sut.location {
            XCTAssertTrue(location.isEqual(to: CLLocation(latitude: 50.023604, longitude: 22.000681)))
        } else {
            XCTFail()
        }
    }
    
    func testCreatingNearLocationsOnCircle() {
        let mockLocation = CLLocation(latitude: 50.123, longitude: -50.123)
        mockLocationManager.mockLocation = mockLocation
        
        /// 100km is around 0.9 degree in latitude 50.123 - 0.9 = 51.023
        let points: [CLLocationCoordinate2D] = [
            CLLocationCoordinate2D(latitude: 51.023, longitude: -50.123),
            CLLocationCoordinate2D(latitude: 49.223, longitude: -50.123)
        ]
        
        sut.pointsOnCircle(center: mockLocation.coordinate, radius: 100000, numberOfPoints: 2)
        XCTAssertEqual(sut.nearLocations.count, points.count)
        sut.nearLocations.enumerated().forEach {
            XCTAssertTrue($0.element.coordinate.isEqual(to: points[$0.offset]))
        }
    }
    
    func testCountOfCreatedNearLocationsPoints() {
        let numberOfPointsToCreate = 10
        let mockLocation = CLLocation(latitude: 50.123, longitude: -50.123)
        mockLocationManager.mockLocation = mockLocation
        
        sut.pointsOnCircle(center: mockLocation.coordinate, radius: 10000, numberOfPoints: numberOfPointsToCreate)
        
        XCTAssertEqual(sut.nearLocations.count, numberOfPointsToCreate)
    }
    
    func testCountOfCreatedNearLocationsPointsShouldFail() {
        let numberOfPointsToCreate = 10
        let mockLocation = CLLocation(latitude: 50.123, longitude: -50.123)
        mockLocationManager.mockLocation = mockLocation
        
        sut.pointsOnCircle(center: mockLocation.coordinate, radius: 10000, numberOfPoints: 12)
        
        XCTAssertNotEqual(sut.nearLocations.count, numberOfPointsToCreate)
    }
    
    func testDistanceOfCreatedNearPoint() {
        let distance: CLLocationDistance = 50000 // 50 km
        let mockLocation = CLLocation(latitude: 50.123, longitude: -50.123)
        mockLocationManager.mockLocation = mockLocation
        
        sut.pointsOnCircle(center: mockLocation.coordinate, radius: distance, numberOfPoints: 2)
        
        if let firstPoint = sut.nearLocations.first {
            let location1 = CLLocation(latitude: firstPoint.coordinate.latitude, longitude: firstPoint.coordinate.longitude)
            let location2 = sut.location ?? CLLocation(latitude: 0, longitude: 0)
            let calculatedDistance = location1.distance(from: location2)
            
            // 100m accuracy
            XCTAssertEqual(calculatedDistance, distance, accuracy: 100)
        } else {
            XCTFail()
        }
    }
    
    func testGetPointVoivodeship() {
        let mockLocation = CLLocation(latitude: 50.023604, longitude: 22.000681) // Rzeszów coordinates -> Podkarpackie
        let expectedVoivodeship = "Podkarpackie"
        
        let expectation = XCTestExpectation(description: "Get point voivodeship completed")
        
        Task {
            let pointVoivodeship = await self.sut.getPointVoivodeship(for: mockLocation)
            XCTAssertEqual(pointVoivodeship, expectedVoivodeship)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testNearPointsVoivodeships() {
        let mockPoints = [LocationData(coordinate: CLLocationCoordinate2D(latitude: 50.023604, longitude: 22.000681)), LocationData(coordinate: CLLocationCoordinate2D(latitude: 50.061049, longitude: 19.937617))] // Cracow and Rzeszów -> małopolskie and podkarpackie
        let expectedArray = ["Podkarpackie", "Małopolskie"]
        let expectation = XCTestExpectation(description: "Get points voivodeships completed")
        
        Task {
            await sut.getNearPointsVoivodeships(for: mockPoints)
            XCTAssertEqual(sut.nearVoivodeships.sorted(), expectedArray.sorted())
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    // X in name to run this test at the end to prevent geocoding throttling from disturbing other tests
    func testXGeocodingThrottling() {
        var locationError: LocationError?
        var cancellables = Set<AnyCancellable>()
        
        sut.locationErrorPublished
            .receive(on: DispatchQueue.main)
            .sink { error in
                locationError = error
            }
            .store(in: &cancellables)
        
        let mockPoints = Array(repeating: LocationData(coordinate: CLLocationCoordinate2D(latitude: 50.023604, longitude: 22.000681)), count: 60)
        let expectation = XCTestExpectation(description: "Should throttle")
        
        Task {
            await sut.getNearPointsVoivodeships(for: mockPoints)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
        XCTAssertEqual(locationError, .geocodeError)
        
        cancellables.forEach { $0.cancel() }
    }
    
    func testCalculatingDistance() {
        let mockLocation = CLLocation(latitude: 50.061049, longitude: 19.937617) // Cracow coordinates -> Małopolskie
        mockLocationManager.mockLocation = mockLocation
        
        if let distance = sut.calculateDistanceFromPoint(to: CLLocation(latitude: 50.041114, longitude: 21.999135)) {
            XCTAssertEqual(distance, 147900, accuracy: CLLocationDistance(250)) // 250m accuracy because of unaccurate measure in maps done to check manager calculations
        } else {
            XCTFail("Calculation returned nil")
        }
    }
    
    func testCalculatingDistanceShouldFail() {
        let mockLocation = CLLocation(latitude: 51.061049, longitude: 19.123617) // Cracow coordinates -> Małopolskie
        mockLocationManager.mockLocation = mockLocation
        
        if let distance = sut.calculateDistanceFromPoint(to: CLLocation(latitude: 50.041114, longitude: 21.999135)) {
            XCTAssertNotEqual(distance, 147900, accuracy: CLLocationDistance(250)) // 250m accuracy because of unaccurate measure in maps done to check manager calculations
        } else {
            XCTFail("Calculation returned nil")
        }
    }

    func testFindingCoordinatesForCityName() {
        let expectation = XCTestExpectation(description: "Geocoding work done")
        
        Task {
            let coordinate = try await sut.findCoordinatesOfCityName(name: "Kraków")
            
            XCTAssertNotNil(coordinate)
            
            if let coordinate = coordinate {
                XCTAssertEqual(coordinate.coordinate.latitude, CLLocation(latitude: 50.05917200, longitude: 19.93704350).coordinate.latitude)
                XCTAssertEqual(coordinate.coordinate.longitude, CLLocation(latitude: 50.05917200, longitude: 19.93704350).coordinate.longitude)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testFindingCoordinatesForCityNameShouldFail() {
        let expectation = XCTestExpectation(description: "Geocoding work done")
        
        Task {
            let coordinate = try await sut.findCoordinatesOfCityName(name: "Warszawa")
            
            XCTAssertNotNil(coordinate)
            
            if let coordinate = coordinate {
                XCTAssertNotEqual(coordinate.coordinate.latitude, CLLocation(latitude: 50.05917200, longitude: 19.93704350).coordinate.latitude)
                XCTAssertNotEqual(coordinate.coordinate.longitude, CLLocation(latitude: 50.05917200, longitude: 19.93704350).coordinate.longitude)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testGeocodingRateLimiter() {
        for i in 0...125 {
            let expectation = XCTestExpectation(description: "Geocoding work done")
            
            Task {
                let coordinate = try await sut.findCoordinatesOfCityName(name: "Mielec")

                XCTAssertNotNil(coordinate)
                
                if let coordinate = coordinate {
                    XCTAssertNotEqual(coordinate.coordinate.latitude, CLLocation(latitude: 50.05917200, longitude: 19.93704350).coordinate.latitude)
                    XCTAssertNotEqual(coordinate.coordinate.longitude, CLLocation(latitude: 50.05917200, longitude: 19.93704350).coordinate.longitude)
                    expectation.fulfill()
                }
            }
            
            wait(for: [expectation], timeout: 180.0)
        }
    }
}
