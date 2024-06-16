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
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
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
        XCTAssertEqual(mockLocationManager.authorizationStatus, .notDetermined)
    }
    
    func testGetVoivodeship() {
        let mockLocation = CLLocation(latitude: 50.061049, longitude: 19.937617) // Cracow coordinates -> Małopolskie
        let expectation = expectation(description: "Geocoding completed")
        mockLocationManager.mockLocation = mockLocation
        
        Task {
            await sut.getUserVoivodeship()
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("Expectation timed out with error: \(error)")
            }
        }
        
        XCTAssertEqual(sut.voivodeship, "Małopolskie")
    }
    
    func testUpdatingLocation() {        
        mockLocationManager.simulateLocationUpdate(location: CLLocation(latitude: 50.023604, longitude: 22.000681)) // Rzeszów coordinates -> Podkarpackie
        
        if let location = sut.location {
            XCTAssertTrue(location.isEqual(to: CLLocation(latitude: 50.023604, longitude: 22.000681)))
        } else {
            XCTFail()
        }
    }
    
    func testUpdateLocation() {
        
    }
}
