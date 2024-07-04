//
//  NetworkManagerTestsDates.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import XCTest
@testable import Znajdz_Termin

var mockDataDates = """
{
  "meta": {
    "context": "https://api.nfz.gov.pl/app-itl-api/schemas/#queue",
    "count": 211,
    "title": "queue",
    "page": 1,
    "url": "https://api.nfz.gov.pl/app-itl-api/schema/queue",
    "limit": 1,
    "provider": "Narodowy Fundusz Zdrowia",
    "date-published": "2019-02-26T10:49:23+01:00",
    "date-modified": "2024-06-27T13:16:42+02:00",
    "description": "Zasób zwraca pierwszy dostępny termin leczenia dla każdego świadczenia medycznego zgodnie z wybranymi parametrami wyszukiwania. Odpowiedź zawiera szczegółowe informacje  oraz listę świadczeń medycznych we właściwej kolejności wyświetlania (według pierwszej dostępnego terminu leczenia)",
    "keywords": "kolejki,terminy leczenia,Narodowy Fundusz Zdrowia,termin,lekarz,poradnia,przychodnia,leczenie,terminy,wolne terminy",
    "language": "PL",
    "content-type": "application/json; charset=utf-8",
    "is-part-of": "Terminy leczenia",
    "message": null
  },
  "links": {
    "first": "/app-itl-api/queues?page=1&limit=1&format=json&case=1&province=06&benefit=orto",
    "prev": null,
    "self": "/app-itl-api/queues?page=1&limit=1&format=json&case=1&province=06&benefit=orto",
    "next": "/app-itl-api/queues?page=2&limit=1&format=json&case=1&province=06&benefit=orto",
    "last": "/app-itl-api/queues?page=211&limit=1&format=json&case=1&province=06&benefit=orto"
  },
  "data": [
    {
      "type": "queue",
      "id": "1bd85199-675c-6ec5-e063-b4200a0aca7f",
      "attributes": {
        "case": 1,
        "benefit": "ODDZIAŁ CHIRURGII URAZOWO-ORTOPEDYCZNEJ DLA DZIECI",
        "many-places": "N",
        "provider": "UNIWERSYTECKI SZPITAL DZIECIĘCY W KRAKOWIE",
        "provider-code": "061/100203",
        "regon-provider": "351375886",
        "nip-provider": "6792525795",
        "teryt-provider": "1261011",
        "place": "ODDZIAŁ ORTOPEDYCZNO-URAZOWY Z CENTRUM LECZENIA ARTROGRYPOZY",
        "address": "UL. WIELICKA 265",
        "locality": "KRAKÓW-PODGÓRZE",
        "phone": "+48 12 658 20 11",
        "teryt-place": "1261049",
        "registry-number": "000000018602-W-12",
        "id-resort-part-VII": "022",
        "id-resort-part-VIII": "4581",
        "benefits-for-children": "Y",
        "covid-19": "N",
        "toilet": "Y",
        "ramp": "Y",
        "car-park": "Y",
        "elevator": "Y",
        "latitude": 50.0125589,
        "longitude": 20.000072,
        "statistics": {
          "provider-data": {
            "awaiting": 0,
            "removed": 0,
            "average-period": 0,
            "update": "2024-05"
          },
          "computed-data": null
        },
        "dates": {
          "applicable": true,
          "date": "2024-06-25",
          "date-situation-as-at": "2024-06-25"
        },
        "benefits-provided": null
      }
    }
  ]
}
"""

class URLSessionMockDates: URLSessionProtocol {
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

final class NetworkManagerTestsDates: XCTestCase {

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
    
    func testCreatingURLForQueues() {
        do {
            let url = try NetworkManager.shared.createURL(path: .queues, province: "06", benefit: "orto")
            XCTAssertEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/queues?page=1&limit=25&format=json&case=1&province=06&benefit=orto&benefitForChildren=false&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testCreatingURLForDates() {
        do {
            let url = try NetworkManager.shared.createURL(path: .queues, caseNumber: 1, province: "06", benefit: "orto")
            XCTAssertEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/queues?page=1&limit=25&format=json&case=1&province=06&benefit=orto&benefitForChildren=false&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testCreatingURLForDatesShouldFail() {
        do {
            let url = try NetworkManager.shared.createURL(path: .queues, caseNumber: 1, province: "06", benefit: "orto")
            XCTAssertNotEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/queues?page=1&limit=25&format=json&case=1&province=02&benefit=orto&benefitForChildren=false&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testDecodingDataShouldSuccess() {
        let data = Data(mockDataDates.utf8)
        do {
            let decodedData = try NetworkManager.shared.decodeData(from: data, isDateData: true)
            
            if let decodedDataDates = decodedData.apiResponse {
                XCTAssertEqual(decodedDataDates.meta.count, 211)
            } else {
                XCTFail()
            }
        } catch {
            XCTFail()
        }
    }
    
    func testDecodingDataShouldSuccessDataArray() {
        let data = Data(mockDataDates.utf8)
        do {
            let decodedData = try NetworkManager.shared.decodeData(from: data, isDateData: true)
            
            if let decodedDataDates = decodedData.apiResponse {
                XCTAssertEqual(decodedDataDates.data.first?.attributes.provider, "UNIWERSYTECKI SZPITAL DZIECIĘCY W KRAKOWIE")
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
            let _ = try NetworkManager.shared.decodeData(from: data, isDateData: true)
            XCTFail()
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.badJSON)
        }
    }
    
    func testFetchingMultiPageBenefits() {
        let sut = NetworkManager.shared
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.datesDataArray.removeAll()
        Task {
            await NetworkManager.shared.fetchDates(benefitName: "orto", caseNumber: 1, province: "06")
            XCTAssertEqual(sut.datesDataArray.count, 211)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testFetchingMultiPageBenefitsManyPlaces() {
        let sut = NetworkManager.shared
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.datesDataArray.removeAll()
        Task {
            await NetworkManager.shared.fetchDates(benefitName: "poradnia", caseNumber: 1, province: "06")
            XCTAssertEqual(sut.datesDataArray.count, 2360)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 120.0)
    }
    
    func testFetchingMultiPageBenefitsManyPlacesOnlyFirstPage() {
        let sut = NetworkManager.shared
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.datesDataArray.removeAll()
        Task {
            await NetworkManager.shared.fetchDates(benefitName: "poradnia", caseNumber: 1, province: "06", onlyOnePage: true)
            XCTAssertEqual(sut.datesDataArray.count, 25)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCreatingNextPagerURL() {
        let sut = NetworkManager.shared
        
        let nextPage = sut.createNextPageURL(nextPageString: "/app-itl-api/queues?page=2&limit=25&format=json&case=1&province=06&benefit=poradnia")
        
        XCTAssertEqual(nextPage, URL(string:"https://api.nfz.gov.pl/app-itl-api/queues?page=2&limit=25&format=json&case=1&province=06&benefit=poradnia"))
    }

    func testPaginationFetchingForDates() {
        let sut = NetworkManager.shared
        
        let expectation = XCTestExpectation(description: "Fetching first page completed")
        let expectation2 = XCTestExpectation(description: "Fetching second page completed")
        let expectation3 = XCTestExpectation(description: "Fetching third page completed")
        let expectation4 = XCTestExpectation(description: "Fetching next page nil page")
        
        sut.datesDataArray.removeAll()
        Task {
            await sut.fetchDates(benefitName: "poradnia alergologiczna", caseNumber: 1, province: "06", onlyOnePage: true)
            expectation.fulfill()
            XCTAssertEqual(sut.datesDataArray.count, 25)
            
            await sut.fetchMoreDates()
            expectation2.fulfill()
            XCTAssertEqual(sut.datesDataArray.count, 50)
            
            await sut.fetchMoreDates()
            expectation3.fulfill()
            XCTAssertEqual(sut.datesDataArray.count, 59)
            
            await sut.fetchMoreDates()
            expectation4.fulfill()
            XCTAssertEqual(sut.datesDataArray.count, 59)
        }
        
        wait(for: [expectation, expectation2, expectation3, expectation4], timeout: 15.0)
    }
}
