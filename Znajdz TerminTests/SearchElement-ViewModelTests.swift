//
//  SearchElement-ViewModelTests.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 25/06/2024.
//

import XCTest
import CoreLocation
import Combine
@testable import Znajdz_Termin

class LocationManagerMockVoivodeship: LocationManagerProtocol {
    var nearVoivodeships: [String] = []
    
    var authorizationStatus: CLAuthorizationStatus = .authorizedAlways
    
    var location: CLLocation? = CLLocation(latitude: 50.061049, longitude: 19.937617)
    
    var voivodeship: String = ""
    
    var locationErrorPublished: PassthroughSubject<Znajdz_Termin.LocationError?, Never> = PassthroughSubject()
    
    var locationWorkDone: PassthroughSubject<Bool, Never> = PassthroughSubject()
    
    func requestWhenInUseAuthorization() {
    }
    
    func calculateDistanceFromPoint(to location: CLLocation) -> CLLocationDistance? {
        return 118160
    }
    
    func findCoordinatesOfCityName(name: String) async throws -> CLLocation? {
        return CLLocation(latitude: 49.03282250, longitude: 20.34864810)
    }
}

final class SearchElement_ViewModelTests: XCTestCase {
    var sut: SearchElementView.ViewModel!

    @MainActor override func setUpWithError() throws {
        sut = SearchElementView.ViewModel(locationManager: LocationManagerMockVoivodeship())
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func testConvertingStringVoivodeshipToStringNumber() {
        let number = sut.getVoivodeshipNumber(selectedVoivodeship: "łódzkie")
        
        XCTAssertEqual(number, "05")
    }
    
    func testConvertingStringVoivodeshipToStringNumberShouldFail() {
        let number = sut.getVoivodeshipNumber(selectedVoivodeship: "łódzkie")
        
        XCTAssertNotEqual(number, "11")
    }
    
    func testCheckingInput() {
        sut.checkNewValueInput(oldValue: "por", newValue: "pora")
        
        XCTAssertEqual(sut.shouldShowHint, true)
    }
    
    func testCheckingInputLessThanThree() {
        sut.benefitsArray = ["test"]
        sut.checkNewValueInput(oldValue: "p", newValue: "po")
        
        XCTAssertEqual(sut.benefitsArray.count, 0)
    }
    
    func testCheckTextCount() {
        XCTAssertEqual(sut.checkTextCount(text: "pora"), true)
    }
    
    func testCheckingPickedVoivodeship() {
        let expectation = expectation(description: "User voivodeship checked")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let returned = self.sut.checkIfUserSelectedOtherVoivodeship(selectedVoivodeship: "małopolskie")

            XCTAssertEqual(returned, true)
            XCTAssertNotEqual(returned, false)

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2)
    }}
