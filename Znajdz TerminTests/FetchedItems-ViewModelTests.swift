//
//  FetchedItems-ViewModelTests.swift
//  Znajdz TerminTests
//
//  Created by Maksymilian Stan on 03/07/2024.
//

import XCTest
import CoreLocation
import Combine
@testable import Znajdz_Termin

class LocationManagerMock: LocationManagerProtocol {
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

class NetworkManagerMock: NetworkManagerProtocol {
    @Published var benefitsDataArray: [String] = []
    var benefitsDataArrayPublisher: Published<[String]>.Publisher { $benefitsDataArray }
    
    @Published var datesDataArray: [Znajdz_Termin.DataElement] = []
    var datesDataArrayPublisher: Published<[Znajdz_Termin.DataElement]>.Publisher { $datesDataArray }
    
    @Published var networkError: Znajdz_Termin.NetworkError?
    var networkErrorPublisher: Published<Znajdz_Termin.NetworkError?>.Publisher { $networkError }
    
    @Published var benefitsArray: [String] = []
    var benefitsArrayPublisher: Published<[String]>.Publisher { $benefitsDataArray }
    
    @Published var canFetchMorePages: Bool = true
    var canFetchMorePagesPublisher: Published<Bool>.Publisher { $canFetchMorePages }
    
    var nextPageURL: String?
    
    func createURL(path: Znajdz_Termin.URLPathType, currentPage: Int, caseNumber: Int, province: String?, benefit: String, isForKids: Bool) throws -> URL {
        
        return URL(string: "")!
    }
    
    func fetchData(from url: URL, session: any Znajdz_Termin.URLSessionProtocol) async throws -> (Data, URLResponse) {
        
        return (Data(), URLResponse())
    }
    
    func createNextPageURL(nextPageString: String?) -> URL? {
        return nil
    }
    
    func fetchDates(benefitName: String, nextPage: URL?, caseNumber: Int, isForKids: Bool, province: String, onlyOnePage: Bool) async {
        
    }
    
    func fetchMoreDates() async {
        
    }
    
    func resetNetworkFetchingDates() {
        
    }
    
    
}

final class FetchedItems_ViewModelTests: XCTestCase {
    var sut: FetchedItemsView.ViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    @MainActor override func setUpWithError() throws {
        sut = FetchedItemsView.ViewModel(networkManager: NetworkManagerMock(), locationManager: LocationManagerMock())
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        sut = nil
        cancellables = []
    }
    
    @MainActor func testProcessingNewItems() {
        sut.processedItemIDs = ["1", "2", "3"]
        
        let newItemsArray = [DataElement(type: "", id: "1", attributes: .defaultAttributes), DataElement(type: "", id: "2", attributes: .defaultAttributes), DataElement(type: "", id: "3", attributes: .defaultAttributes), DataElement(type: "", id: "4", attributes: .defaultAttributes), DataElement(type: "", id: "5", attributes: .defaultAttributes)]
        
        sut.processNewItems(newItems: newItemsArray)
        
        XCTAssertEqual(sut.queueItems.count, 2)
        XCTAssertNotEqual(sut.queueItems.count, 5)
    }
    
    @MainActor func testCalculatingDistanceAddingToProcessedItemsDictionary() {
        let expectation = XCTestExpectation(description: "Calculating for all items done")
        
        let itemsToProcess = [DataElement(type: "", id: "1", attributes: .defaultAttributes), DataElement(type: "", id: "2", attributes: .defaultAttributesWithoutLocation), DataElement(type: "", id: "3", attributes: .defaultAttributes), DataElement(type: "", id: "4", attributes: .defaultAttributes), DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation)]
        
        Task {
            sut.calculateDistances(for: itemsToProcess)
            
            try await Task.sleep(nanoseconds: 2_000_000_000)
            
            XCTAssertEqual(sut.alreadyProcessedCities.count, 1)
            XCTAssertNotEqual(sut.alreadyProcessedCities.count, 2)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    @MainActor func testCalculatingDistanceUpdatingDistance() {
        let expectation = XCTestExpectation(description: "Calculating for all items done")
        
        let itemsToProcess = [DataElement(type: "", id: "1", attributes: .defaultAttributes), DataElement(type: "", id: "2", attributes: .defaultAttributesWithoutLocation), DataElement(type: "", id: "3", attributes: .defaultAttributes), DataElement(type: "", id: "4", attributes: .defaultAttributes), DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation)]
        
        sut.$queueItems.sink { queueItems in
            if queueItems.filter({ $0.distance != "Obliczam..." }).count == itemsToProcess.count {
                expectation.fulfill()
            }
        }
        .store(in: &cancellables)
        
        sut.processNewItems(newItems: itemsToProcess)
        
        wait(for: [expectation], timeout: 30.0)
        
        sut.queueItems.forEach {
            XCTAssertEqual($0.distance, "118.16 km")
        }
    }
    
    @MainActor func testSortingItemsByDistance() {
        let itemsToProcess = [QueueItem(queueResult: DataElement.defaultDataElement, distance: "225.99 km"), QueueItem(queueResult: DataElement(type: "", id: "2", attributes: .defaultAttributes), distance: "12.93 km"), QueueItem(queueResult: DataElement(type: "", id: "3", attributes: .defaultAttributesWithoutLocation), distance: "11.92 km"), QueueItem(queueResult: DataElement(type: "", id: "4", attributes: .defaultAttributesWithoutLocation2), distance: "9.22 km"), QueueItem(queueResult: DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation3), distance: "0.12 km")]
        
        sut.sortItems(oldValue: .date, newValue: .distance, queryItems: itemsToProcess)
        
        let sortedItemsToProcess = [
            QueueItem(queueResult: DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation3), distance: "0.12 km"),
            QueueItem(queueResult: DataElement(type: "", id: "4", attributes: .defaultAttributesWithoutLocation2), distance: "9.22 km"),
            QueueItem(queueResult: DataElement(type: "", id: "3", attributes: .defaultAttributesWithoutLocation), distance: "11.92 km"),
            QueueItem(queueResult: DataElement(type: "", id: "2", attributes: .defaultAttributes), distance: "12.93 km"),
            QueueItem(queueResult: DataElement.defaultDataElement, distance: "225.99 km")
        ]

        XCTAssertEqual(sut.queueItems.last?.id, sortedItemsToProcess.last?.id)
    }
    
    @MainActor func testSortingItemsByAwaiting() {
        let itemsToProcess = [QueueItem(queueResult: DataElement.defaultDataElement, distance: "225.99 km"), QueueItem(queueResult: DataElement(type: "", id: "2", attributes: .defaultAttributes), distance: "12.93 km"), QueueItem(queueResult: DataElement(type: "", id: "3", attributes: .defaultAttributesWithoutLocation), distance: "11.92 km"), QueueItem(queueResult: DataElement(type: "", id: "4", attributes: .defaultAttributesWithoutLocation2), distance: "9.22 km"), QueueItem(queueResult: DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation3), distance: "0.12 km")]
        
        sut.sortItems(oldValue: .distance, newValue: .awaiting, queryItems: itemsToProcess)
        
        let sortedItemsToProcess = [
            QueueItem(queueResult: DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation3), distance: "0.12 km"),
            QueueItem(queueResult: DataElement(type: "", id: "4", attributes: .defaultAttributesWithoutLocation2), distance: "9.22 km"),
            QueueItem(queueResult: DataElement(type: "", id: "2", attributes: .defaultAttributes), distance: "12.93 km"),
            QueueItem(queueResult: DataElement.defaultDataElement, distance: "225.99 km"),
            QueueItem(queueResult: DataElement(type: "", id: "3", attributes: .defaultAttributesWithoutLocation), distance: "11.92 km")
        ]
        
        XCTAssertEqual(sut.queueItems.last?.id, sortedItemsToProcess.last?.id)
    }
    
}
