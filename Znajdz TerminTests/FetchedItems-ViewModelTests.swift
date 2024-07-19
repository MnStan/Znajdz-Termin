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

class NetworkManagerMock: NetworkManagerProtocol {
    func fetchAllRemainingDates() async {
    }
    
    @Published var datesNearDataArray: [Znajdz_Termin.DataElement] = []
    var datesNearDataArrayPublisher: Published<[Znajdz_Termin.DataElement]>.Publisher { $datesNearDataArray }
    
    @Published var benefitsDataArray: [String] = []
    var benefitsDataArrayPublisher: Published<[String]>.Publisher { $benefitsDataArray }
    
    @Published var datesDataArray: [Znajdz_Termin.DataElement] = []
    var datesDataArrayPublisher: Published<[Znajdz_Termin.DataElement]>.Publisher { $datesDataArray }
    
    @Published var networkError: Znajdz_Termin.NetworkError?
    var networkErrorPublisher: Published<Znajdz_Termin.NetworkError?>.Publisher { $networkError }
    
    @Published var benefitsArray: [String] = []
    var benefitsArrayPublisher: Published<[String]>.Publisher { $benefitsDataArray }
    
    @Published var canFetchMorePages: Bool = false
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
    
    func fetchDates(benefitName: String, nextPage: URL?, caseNumber: Int, isForKids: Bool, province: String, onlyOnePage: Bool, userVoivodeship: Bool) async {
        self.datesNearDataArray = [.defaultDataElement, .defaultDataElement, .defaultDataElement]
    }
}

final class FetchedItems_ViewModelTests: XCTestCase {
    var sut: FetchedItemsView.ViewModel!
    var cancellables: Set<AnyCancellable> = []
    
    @MainActor override func setUpWithError() throws {
        sut = FetchedItemsView.ViewModel(networkManager: NetworkManagerMock(), locationManager: LocationManagerMock())
        cancellables.forEach { $0.cancel() }
    }
    
    override func tearDownWithError() throws {
        sut = nil
        cancellables.forEach { $0.cancel() }
    }
    
    func testProcessingNewItems() {
        let expectation = expectation(description: "Processed on main thread")
        sut.processedItemIDs = ["1", "2", "3"]
        
        let newItemsArray = [DataElement(type: "", id: "1", attributes: .defaultAttributes), DataElement(type: "", id: "2", attributes: .defaultAttributes), DataElement(type: "", id: "3", attributes: .defaultAttributes), DataElement(type: "", id: "4", attributes: .defaultAttributes), DataElement(type: "", id: "5", attributes: .defaultAttributes)]
        
        self.sut.processNewItems(newItems: newItemsArray)
        
        DispatchQueue.main.async {
            XCTAssertEqual(self.sut.queueItems.count, 2)
            XCTAssertNotEqual(self.sut.queueItems.count, 5)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    func testCalculatingDistanceUpdatingDistance() async throws {
        let expectation = expectation(description: "Distance calculation completed")
        
        let itemsToProcess = [
            DataElement(type: "", id: "1", attributes: .defaultAttributes),
            DataElement(type: "", id: "2", attributes: .defaultAttributesWithoutLocation),
            DataElement(type: "", id: "3", attributes: .defaultAttributes),
            DataElement(type: "", id: "4", attributes: .defaultAttributes),
            DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation)
        ]
        
        var cancellable: AnyCancellable?
        cancellable = sut.$isCalculatingDistances
            .dropFirst()
            .sink { isCalculating in
                if !isCalculating {
                    cancellable?.cancel()
                    expectation.fulfill()
                }
            }
        
        sut.processNewItems(newItems: itemsToProcess)
        
        await fulfillment(of: [expectation], timeout: 5)
        
        XCTAssertEqual(sut.queueItems.count, itemsToProcess.count, "Should have processed all items")
        
        for item in sut.queueItems {
            XCTAssertEqual(item.distance, "118.16 km")
        }
    }
    
    @MainActor func testSortingItemsByDistance() {
        let expectation = XCTestExpectation(description: "Sorting completed")
        
        let itemsToProcess = [QueueItem(queueResult: DataElement.defaultDataElement, distance: "225.99 km"), QueueItem(queueResult: DataElement(type: "", id: "2", attributes: .defaultAttributes), distance: "12.93 km"), QueueItem(queueResult: DataElement(type: "", id: "3", attributes: .defaultAttributesWithoutLocation), distance: "11.92 km"), QueueItem(queueResult: DataElement(type: "", id: "4", attributes: .defaultAttributesWithoutLocation2), distance: "9.22 km"), QueueItem(queueResult: DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation3), distance: "0.12 km")]
        
        Task {
            await sut.performSorting(sortingOption: .distance, queryItems: itemsToProcess)
        }
        
        let sortedItemsToProcess = [
            QueueItem(queueResult: DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation3), distance: "0.12 km"),
            QueueItem(queueResult: DataElement(type: "", id: "4", attributes: .defaultAttributesWithoutLocation2), distance: "9.22 km"),
            QueueItem(queueResult: DataElement(type: "", id: "3", attributes: .defaultAttributesWithoutLocation), distance: "11.92 km"),
            QueueItem(queueResult: DataElement(type: "", id: "2", attributes: .defaultAttributes), distance: "12.93 km"),
            QueueItem(queueResult: DataElement.defaultDataElement, distance: "225.99 km")
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.sut.queueItems.last?.id, sortedItemsToProcess.last?.id)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
    
    @MainActor func testSortingItemsByAwaiting() {
        let expectation = XCTestExpectation(description: "Sorting completed")
        
        let itemsToProcess = [QueueItem(queueResult: DataElement.defaultDataElement, distance: "225.99 km"), QueueItem(queueResult: DataElement(type: "", id: "2", attributes: .defaultAttributes), distance: "12.93 km"), QueueItem(queueResult: DataElement(type: "", id: "3", attributes: .defaultAttributesWithoutLocation), distance: "11.92 km"), QueueItem(queueResult: DataElement(type: "", id: "4", attributes: .defaultAttributesWithoutLocation2), distance: "9.22 km"), QueueItem(queueResult: DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation3), distance: "0.12 km")]
        
        Task {
            await sut.performSorting(sortingOption: .awaiting, queryItems: itemsToProcess)
        }
        
        let sortedItemsToProcess = [
            QueueItem(queueResult: DataElement(type: "", id: "5", attributes: .defaultAttributesWithoutLocation3), distance: "0.12 km"),
            QueueItem(queueResult: DataElement(type: "", id: "4", attributes: .defaultAttributesWithoutLocation2), distance: "9.22 km"),
            QueueItem(queueResult: DataElement(type: "", id: "2", attributes: .defaultAttributes), distance: "12.93 km"),
            QueueItem(queueResult: DataElement.defaultDataElement, distance: "225.99 km"),
            QueueItem(queueResult: DataElement(type: "", id: "3", attributes: .defaultAttributesWithoutLocation), distance: "11.92 km")
        ]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            XCTAssertEqual(self.sut.queueItems.last?.id, sortedItemsToProcess.last?.id)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5.0)
    }
}
