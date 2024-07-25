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
    static let rateLimiter = RateLimiter()
    var sut: NetworkManager!

    override func setUpWithError() throws {
        sut = NetworkManager(rateLimiter: NetworkManagerTestsDates.rateLimiter)
        sut.datesDataArray.removeAll()
        sut.benefitsDataArray.removeAll()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testCreatingURLForQueues() {
        do {
            let url = try sut.createURL(path: .queues, province: "06", benefit: "orto")
            XCTAssertEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/queues?page=1&limit=25&format=json&case=1&province=06&benefit=orto&benefitForChildren=false&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testCreatingURLForDates() {
        do {
            let url = try sut.createURL(path: .queues, caseNumber: 1, province: "06", benefit: "orto")
            XCTAssertEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/queues?page=1&limit=25&format=json&case=1&province=06&benefit=orto&benefitForChildren=false&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testCreatingURLForDatesShouldFail() {
        do {
            let url = try sut.createURL(path: .queues, caseNumber: 1, province: "06", benefit: "orto")
            XCTAssertNotEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/queues?page=1&limit=25&format=json&case=1&province=02&benefit=orto&benefitForChildren=false&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testDecodingDataShouldSuccess() {
        let data = Data(mockDataDates.utf8)
        do {
            let decodedData = try sut.decodeData(from: data, isDateData: true)
            
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
            let decodedData = try sut.decodeData(from: data, isDateData: true)
            
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
            let _ = try sut.decodeData(from: data, isDateData: true)
            XCTFail()
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.badJSON)
        }
    }
    
    func testFetchingMultiPageBenefits() {
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.datesDataArray.removeAll()
        Task {
            await sut.fetchDates(benefitName: "orto", caseNumber: 1, province: "06")
            XCTAssertEqual(sut.datesDataArray.count, 211)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testFetchingMultiPageBenefitsManyPlacesOnlyFirstPage() {
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.datesDataArray.removeAll()
        Task {
            await sut.fetchDates(benefitName: "poradnia", caseNumber: 1, province: "06", onlyOnePage: true)
            XCTAssertEqual(sut.datesDataArray.count, 25)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 10.0)
    }
    
    func testCreatingNextPagerURL() {
        let nextPage = sut.createNextPageURL(nextPageString: "/app-itl-api/queues?page=2&limit=25&format=json&case=1&province=06&benefit=poradnia")
        
        XCTAssertEqual(nextPage, URL(string:"https://api.nfz.gov.pl/app-itl-api/queues?page=2&limit=25&format=json&case=1&province=06&benefit=poradnia"))
    }

    func testXPaginationFetchingForDates() {
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
            XCTAssertEqual(sut.datesDataArray.count, 58)
            
            await sut.fetchMoreDates()
            expectation4.fulfill()
            XCTAssertEqual(sut.datesDataArray.count, 58)
        }
        
        wait(for: [expectation, expectation2, expectation3, expectation4], timeout: 15.0)
    }
    
    func testCreatingURLForBenefits() {
        do {
            let url = try sut.createURL(path: .benefits, benefit: "orto")
            XCTAssertEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/benefits?page=1&limit=25&format=json&name=orto&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testCreatingURLForBenefitsShouldNotEqual() {
        do {
            let url = try sut.createURL(path: .queues, benefit: "orto")
            XCTAssertNotEqual(url.absoluteString, "https://api.nfz.gov.pl/app-itl-api/benefits?page=1&limit=25&format=json&name=orto&api-version=1.3")
        } catch {
            XCTFail()
        }
    }
    
    func testfetchBenefitsShouldSuccess() {
        let url = URL(string: "https://example.com")!
        
        let mockSession = URLSessionMockDates()
        mockSession.mockData = Data(mockDataBenefit.utf8)
        mockSession.mockResponse = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        Task {
            do {
                let (data, response) = try await sut.fetchData(from: url, session: mockSession)
                XCTAssertEqual(data, mockSession.mockData)
                XCTAssertEqual((response as? HTTPURLResponse)?.statusCode, 200)
                expectation.fulfill()
            } catch {
                XCTFail()
            }
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testDecodingDataShouldSuccess2() {
        let data = Data(mockDataBenefit.utf8)
        do {
            let decodedData = try sut.decodeData(from: data)
            
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
            let decodedData = try sut.decodeData(from: data)
            
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
    
    func testDecodingDataShouldFail2() {
        let data = Data("testData".utf8)
        do {
            let _ = try sut.decodeData(from: data)
            XCTFail()
        } catch {
            XCTAssertEqual(error as? NetworkError, NetworkError.badJSON)
        }
    }
    
    func testFetchingOnePageBenefit() {
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.benefitsDataArray.removeAll()
        Task {
            await sut.fetchBenefits(benefitName: "ortop")
            XCTAssertEqual(sut.benefitsDataArray.count, 3)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    func testFetchingMultiPageBenefits2() {
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        sut.benefitsDataArray.removeAll()
        Task {
            await sut.fetchBenefits(benefitName: "poradnia")
            XCTAssertEqual(sut.benefitsDataArray.count, 163)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
    
    func testXRateLimiterForApi() {
        for _ in 0...5 {
            let expectation = XCTestExpectation(description: "Fetching completed")
            
            sut.benefitsDataArray.removeAll()
            Task {
                await sut.fetchBenefits(benefitName: "poradnia")
                XCTAssertEqual(sut.benefitsDataArray.count, 163)
                expectation.fulfill()
            }
            
            wait(for: [expectation], timeout: 30.0)
        }
    }
    
    func testFetchingNearVoivoideship() {
        let expectation = XCTestExpectation(description: "Fetching completed")
        
        Task {
            await sut.fetchDates(benefitName: "orto", nextPage: nil, caseNumber: 1, isForKids: false, province: "01", onlyOnePage: false, userVoivodeship: false)
            XCTAssertEqual(sut.datesNearDataArray.count, 190)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 30.0)
    }
}
