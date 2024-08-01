//
//  Znajdz_TerminTests.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 08/05/2024.
//

import XCTest
@testable import Znajdz_Termin

final class Znajdz_TerminTests: XCTestCase {
    func testConvertStringToDate() {
        let dateString = "2024-08-01"
        let expectedDateComponents = DateComponents(year: 2024, month: 8, day: 1)
        let calendar = Calendar.current
        
        let date = dateString.convertToDate()
        
        XCTAssertNotNil(date, "Date should not be nil")
        
        if let date = date {
            let components = calendar.dateComponents([.year, .month, .day], from: date)
            XCTAssertEqual(components.year, expectedDateComponents.year)
            XCTAssertEqual(components.month, expectedDateComponents.month)
            XCTAssertEqual(components.day, expectedDateComponents.day)
        }
    }
    
    func testCombineDateAndTime() {
        let calendar = Calendar.current
        let dateComponents = DateComponents(year: 2024, month: 8, day: 1)
        let timeComponents = DateComponents(hour: 15, minute: 30, second: 0)

        guard let datePart = calendar.date(from: dateComponents),
              let timePart = calendar.date(from: timeComponents) else {
            XCTFail("Failed to create date and time for testing.")
            return
        }

        let combinedDate = datePart.combine(time: timePart)

        XCTAssertNotNil(combinedDate, "Combined date should not be nil")
        let combinedComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: combinedDate!)

        XCTAssertEqual(combinedComponents.year, 2024)
        XCTAssertEqual(combinedComponents.month, 8)
        XCTAssertEqual(combinedComponents.day, 1)
        XCTAssertEqual(combinedComponents.hour, 15)
        XCTAssertEqual(combinedComponents.minute, 30)
        XCTAssertEqual(combinedComponents.second, 0)
    }
}
