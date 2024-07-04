//
//  DetailItem-ViewModelTests.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 04/07/2024.
//

import XCTest
@testable import Znajdz_Termin

final class DetailItem_ViewModelTests: XCTestCase {
    var sut: DetailItemView.ViewModel!

    override func setUpWithError() throws {
        sut = DetailItemView.ViewModel()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testExtractingInternalNumberWithInternalNumber() {
        let inputPhoneNumber: String = "+48 12 264 61 60 WEW 333"
        
        let phoneNumberToDisplay = sut.extractNumberWithInternalNumber(number: inputPhoneNumber)
        
        XCTAssertEqual(phoneNumberToDisplay.number, "+48 12 264 61 60")
        XCTAssertEqual(phoneNumberToDisplay.insideNumber, "333")
    }
    
    func testExtractingInternalNumberWithoutInternalNumber() {
        let inputPhoneNumber: String = "+48 12 264 61 60"
        
        let phoneNumberToDisplay = sut.extractNumberWithInternalNumber(number: inputPhoneNumber)
        
        XCTAssertEqual(phoneNumberToDisplay.number, "+48 12 264 61 60")
        XCTAssertEqual(phoneNumberToDisplay.insideNumber, nil)
    }
    
    func testPreparationOfPhoneNumberWithInsideNumber2() {
        let inputPhoneNumber: String = "+48 12 264 61 60 wew. 333"
        
        let phoneNumberToDisplay = sut.extractNumberWithInternalNumber(number: inputPhoneNumber)
        
        XCTAssertEqual(phoneNumberToDisplay.number, "+48 12 264 61 60")
        XCTAssertEqual(phoneNumberToDisplay.insideNumber, "333")
    }
    
    func testReplacingNumberInBrackets() {
        let inputInBrackets = "(012)267 60 60"
        
        let formattedNumber = sut.removeNumberFromBrackets(number: inputInBrackets)
        
        XCTAssertEqual(formattedNumber, "+48 12 267 60 60")
    }
    
    func testReplacingNumberInBracketsWithoutBrackets() {
        let inputInBrackets = "+48 12 267 60 60"
        
        let formattedNumber = sut.removeNumberFromBrackets(number: inputInBrackets)
        
        XCTAssertEqual(formattedNumber, "+48 12 267 60 60")
    }
    
    func testCheckingIfThereAreTwoNumber() {
        let inputTwoNumbers = "(012)265 46 01; (012)265 46 00"
        
        let checkedNumber = sut.checkIfThereAreTwoNumbers(number: inputTwoNumbers)
        
        XCTAssertEqual(checkedNumber[0], "(012)265 46 01")
        XCTAssertEqual(checkedNumber[1], " (012)265 46 00")
    }
    
    func testCheckingIfThereAreTwoNumberOnlyOneNumber() {
        let inputTwoNumbers = "(012)265 46 01"
        
        let checkedNumber = sut.checkIfThereAreTwoNumbers(number: inputTwoNumbers)
        
        XCTAssertEqual(checkedNumber[0], "(012)265 46 01")
        XCTAssertEqual(checkedNumber[1], nil)
    }
    
    func testCreatingURLForPhoneNumber() {
        let inputNumber = "+48 12 267 60 60"
        
        let generatedURL = sut.createURLFromPhoneNumber(number: inputNumber)
        
        XCTAssertEqual(generatedURL?.absoluteString, "tel:+48%2012%20267%2060%2060")
    }
    
    func testCreatingURLForPhoneNumberWithInternalNumber() {
        let inputNumber = "+48 12 267 60 60"
        let internalNumber = "233"
        
        let generatedURL = sut.createURLFromPhoneNumber(number: inputNumber, internalNumber: internalNumber)
        
        XCTAssertEqual(generatedURL?.absoluteString, "tel:+48%2012%20267%2060%2060,233")
    }
    
    func testPreparationOfPhoneNumber() {
        let inputPhoneNumber: String? = "(018)267 60 60wew. 254"
        
        let phoneNumberToDisplay = sut.preparePhoneNumberToDisplay(phoneNumber: inputPhoneNumber)
        
        XCTAssertEqual(phoneNumberToDisplay.first?.phoneNumber, "+48 18 267 60 60")
        XCTAssertEqual(phoneNumberToDisplay.first?.urlPhoneNumber.absoluteString, "tel:+48%2018%20267%2060%2060,254")
    }

    func testPreparationOfPhoneNumber2() {
        let inputPhoneNumber: String? = "+48 88 392 68 86"
        
        let phoneNumberToDisplay = sut.preparePhoneNumberToDisplay(phoneNumber: inputPhoneNumber)
        
        XCTAssertEqual(phoneNumberToDisplay.first?.phoneNumber, "+48 88 392 68 86")
        XCTAssertEqual(phoneNumberToDisplay.first?.urlPhoneNumber.absoluteString, "tel:+48%2088%20392%2068%2086")
    }
    
    func testPreparationOfPhoneNumber3TwoNumbers() {
        let inputPhoneNumber: String? = "(012)265 46 01; (012)265 46 00"
        
        let phoneNumberToDisplay = sut.preparePhoneNumberToDisplay(phoneNumber: inputPhoneNumber)
        
        XCTAssertEqual(phoneNumberToDisplay.count, 2)
        XCTAssertEqual(phoneNumberToDisplay[0].phoneNumber, "+48 12 265 46 01")
        XCTAssertEqual(phoneNumberToDisplay[0].urlPhoneNumber.absoluteString, "tel:+48%2012%20265%2046%2001")
        XCTAssertEqual(phoneNumberToDisplay[1].phoneNumber, "+48 12 265 46 00")
        XCTAssertEqual(phoneNumberToDisplay[1].urlPhoneNumber.absoluteString, "tel:+48%2012%20265%2046%2000")
    }
}
