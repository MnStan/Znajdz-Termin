//
//  LocalizationManagerTests.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 10/05/2024.
//

import XCTest
@testable import Znajdz_Termin
import CoreLocation

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
        print("\n", sut.nearLocations, "\n")
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
            XCTAssertEqual(sut.nearVoivodeships, expectedArray)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
