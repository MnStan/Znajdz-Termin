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
}
