//
//  CalendarManagerTests.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 15/05/2024.
//

import XCTest
@testable import Znajdz_Termin
import EventKit

class MockEventManager: EKEventStore {
    override func requestFullAccessToEvents(completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        completion(true, nil)
    }
}

final class CalendarManagerTests: XCTestCase {
    var sut: AppCalendarEventManager!
    var mockEventManager: MockEventManager!

    override func setUpWithError() throws {
        mockEventManager = MockEventManager()
        sut = AppCalendarEventManager(eventStore: mockEventManager)
    }

    override func tearDownWithError() throws {
        mockEventManager = nil
        sut = nil
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testAuthorizationStatus() {
        XCTAssertEqual(sut.authorizationStatus, .fullAccess)
    }

}
