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
}
