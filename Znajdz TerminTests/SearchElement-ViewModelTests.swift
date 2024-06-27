//
//  SearchElement-ViewModelTests.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 25/06/2024.
//

import XCTest
@testable import Znajdz_Termin

final class SearchElement_ViewModelTests: XCTestCase {
    var sut: SearchElementView.ViewModel!

    @MainActor override func setUpWithError() throws {
        sut = SearchElementView.ViewModel()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
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
}
