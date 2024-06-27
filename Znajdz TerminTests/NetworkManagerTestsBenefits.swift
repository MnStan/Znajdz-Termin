//
//  NetworkManagerTestsBenefits.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 19/06/2024.
//

import XCTest
@testable import Znajdz_Termin

var mockDataBenefit = """
{
  "meta": {
    "context": "https://api.nfz.gov.pl/app-itl-api/schemas/#place",
    "count": 50,
    "title": "place",
    "page": 1,
    "url": null,
    "limit": 10,
    "provider": "Narodowy Fundusz Zdrowia",
    "date-published": "2019-02-26T10:49:23+01:00",
    "date-modified": "2024-06-19T18:06:54+02:00",
    "description": "Zasób zwraca nazwy miejsc udzielania świadczeń zdrowotnych wybranych z bazy danych z nazwami miejsc, które zawierają pozycje dostarczane przez podmioty świadczące opiekę zdrowotną. Lista miejsc jest wynikiem wyszukiwania według przekazanych parametrów.",
    "keywords": "miejsce, miejsca, miejsce udzielania świadczeń, poradnia, poradnie, szpital, szpitale, adres",
    "language": "PL",
    "content-type": "application/json; charset=utf-8",
    "is-part-of": "Słowniki",
    "message": null
  },
  "links": {
    "first": "/app-itl-api/places?page=1&limit=10&format=json&name=orto",
    "prev": null,
    "self": "/app-itl-api/places?page=1&limit=10&format=json&name=orto",
    "next": "/app-itl-api/places?page=2&limit=10&format=json&name=orto",
    "last": "/app-itl-api/places?page=5&limit=10&format=json&name=orto"
  },
  "data": [
    "GABINET ORTOPEDII I TRAUMATOLOGII NARZĄDU RUCHU DLA DZIECI",
    "KLINICZNY ODDZIAŁ ORTOPEDYCZNY",
    "KLINIKA CHIRURGII URAZOWEJ I ORTOPEDII",
    "KONSULTACYJNA PORADNIA ORTODONCJI",
    "MEDYCYNA SPORTOWA",
    "ODDZIAŁ  URAZOWO-ORTOPEDYCZNY",
    "ODDZIAŁ CHIRURGICZNY O PROFILU CHIRURGII OGÓLNEJ, URAZOWO-ORTOPEDYCZNYM I UROLOGICZNYM",
    "ODDZIAŁ CHIRURGII JEDNEGO DNIA - CHIRURGIA OKA, ORTOPEDIA I TRAUMATOLOGIA",
    "ODDZIAŁ CHIRURGII ORTOPEDYCZNO - URAZOWEJ",
    "ODDZIAŁ CHIRURGII URAZOWEJ I ORTOPEDII"
  ]
}
"""

class URLSessionMock: URLSessionProtocol {
    var mockData: Data?
    var mockResponse: URLResponse?
    var mockError: Error?
    
    func data(from url: URL) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        let data = mockData ?? Data()
        let response = mockResponse ?? URLResponse()
        return (data, response)
    }
}

final class NetworkManagerTestsBenefits: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testCreatingURLForBenefits() {
        do {
            let url = try NetworkManager.shared.createURL(path: .benefits, benefit: "orto")
            XCTAssertEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/benefits?page=1&limit=25&format=json&name=orto&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testCreatingURLForBenefitsShouldNotEqual() {
        do {
            let url = try NetworkManager.shared.createURL(path: .queues, benefit: "orto")
            XCTAssertNotEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/benefits?page=1&limit=25&format=json&name=orto&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testfetchBenefitsShouldSuccess() {
        let url = URL(string: "https://example.com")!
        
        let mockSession = URLSessionMock()
        mockSession.mockData = Data(mockDataBenefit.utf8)
        mockSession.mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        Task {
            do {
                let (data, response) = try await NetworkManager.shared.fetchData(from: url, session: mockSession)
                XCTAssertEqual(data, mockSession.mockData)
                XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testfetchBenefitsShouldThrowError() {
        let url = URL(string: "https://example.com")!
        
        let mockSession = URLSessionMock()
        mockSession.mockData = Data(mockDataBenefit.utf8)
        mockSession.mockResponse = HTTPURLResponse(url: url, statusCode: 500, httpVersion: nil, headerFields: nil)
        
        Task {
            do {
                let (_, _) = try await NetworkManager.shared.fetchData(from: url, session: mockSession)
            } catch {
                XCTAssertEqual(error as? NetworkError, NetworkError.fetchError)
            }
        }
    }
    
    func testDecodingDataShouldSuccess() {
        let data = Data(mockDataBenefit.utf8)
        do {
            let decodedData = try NetworkManager.shared.decodeData(from: data)
            
            if let decodedBenefitsData = decodedData.apiResponseBenefit {
                XCTAssertEqual(decodedBenefitsData.meta.count, 50)
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func testDecodingDataShouldSuccessBenefit() {
        let data = Data(mockDataBenefit.utf8)
        do {
            let decodedData = try NetworkManager.shared.decodeData(from: data)
            
            if let decodedBenefitsData = decodedData.apiResponseBenefit{
                XCTAssertEqual(decodedBenefitsData.data.first, "GABINET ORTOPEDII I TRAUMATOLOGII NARZĄDU RUCHU DLA DZIECI")
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func testDecodingDataShouldSetResponseVariable() {
        let data = Data(mockDataBenefit.utf8)
        let sut = NetworkManager.shared
        do {
            let decodedData = try sut.decodeData(from: data)
            
            if let decodedBenefitsData = decodedData.apiResponseBenefit {
                XCTAssertEqual(decodedBenefitsData.meta.dateModified, "2024-06-19T18:06:54+02:00")
            } else {
                XCTFail()
            }
            
        } catch {
            XCTFail()
        }
    }
    
    func testDecodingDataShouldFail() {
        let data = Data("testData".utf8)
        do {
            let _ = try NetworkManager.shared.decodeData(from: data)
            XCTFail()
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.badJSON)
        }
    }
    
    func testFetchingOnePageBenefit() {
        let sut = NetworkManager.shared
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.benefitsDataArray.removeAll()
        Task {
            await NetworkManager.shared.fetchBenefits(benefitName: "ortop")
            XCTAssertEqual(sut.benefitsDataArray.count, 3)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchingMultiPageBenefits() {
        let sut = NetworkManager.shared
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.benefitsDataArray.removeAll()
        Task {
            await NetworkManager.shared.fetchBenefits(benefitName: "poradnia")
            XCTAssertEqual(sut.benefitsDataArray.count, 163)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testRateLimiterForApi() {
        for _ in 0...5 {
            let sut = NetworkManager.shared
            let expectation = XCTestExpectation(description: "Fetching completed")
            
            sut.benefitsDataArray.removeAll()
            Task {
                await NetworkManager.shared.fetchBenefits(benefitName: "poradnia")
                XCTAssertEqual(sut.benefitsDataArray.count, 163)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
}
