//
//  FetchedItemsView-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import Foundation
import Combine
import CoreLocation

extension FetchedItemsView {
    @MainActor
    class ViewModel: ObservableObject {
        //        private let networkManager = NetworkManager.shared
        private let networkManager: any NetworkManagerProtocol
        private let locationManager: LocationManagerProtocol
        @Published var itemsArray: [DataElement] = []
        @Published var queueItems: [QueueItem] = []
        private var cancellables = Set<AnyCancellable>()
        @Published var networkError: NetworkError?
        @Published var isNetworkWorkDone: Bool = false
        var processedItemIDs: Set<String> = []
        var alreadyProcessedCities: [String: CLLocation] = [:]
        @Published var findingCoordinatesError: Bool = false
        
        init(networkManager: any NetworkManagerProtocol = NetworkManager.shared, locationManager: LocationManagerProtocol = AppLocationManager.shared) {
            self.networkManager = networkManager
            self.locationManager = locationManager
            
            networkManager.datesDataArrayPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] array in
                    self?.processNewItems(newItems: array)
                }
                .store(in: &self.cancellables)
            
            networkManager.networkErrorPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    self?.networkError = error
                }
                .store(in: &self.cancellables)
            
            networkManager.canFetchMorePagesPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] canFetchMore in
                    self?.isNetworkWorkDone = !canFetchMore
                }
                .store(in: &self.cancellables)
        }
        
        deinit {
            cancellables.forEach { $0.cancel() }
        }
        
        func fetchNextPage() async {
            await networkManager.fetchMoreDates()
        }
        
        func resetNetworkManager() {
            networkManager.resetNetworkFetchingDates()
        }
        
        func canLoadMore() -> Bool {
            networkManager.nextPageURL != nil
        }
        
        func processNewItems(newItems: [DataElement]) {
            let newItemsToProcess = newItems.filter { !processedItemIDs.contains($0.id) }
            newItemsToProcess.forEach { processedItemIDs.insert($0.id) }
            
            newItemsToProcess.forEach { item in
                if queueItems.firstIndex(where: { $0.id == item.id }) == nil {
                    let queueItem = QueueItem(queueResult: item, distance: "Czekam...")
                    queueItems.append(queueItem)
                }
            }
            
            Task {
                await calculateDistances(for: newItemsToProcess)
            }
        }
        
        
        func calculateDistances(for itemsToProcess: [DataElement]) async {
            guard let userLocation = locationManager.location else {
                return
            }
            
            for item in itemsToProcess {
                var distance: String
                
                if let latitude = item.attributes.latitude, let longitude = item.attributes.longitude {
                    let itemLocation = CLLocation(latitude: latitude, longitude: longitude)
                    let distanceValue = userLocation.distance(from: itemLocation)
                    distance = String(format: "%.2f", distanceValue / 1000) + " km"
                } else {
                    distance = "Czekam..."
                    if let city = item.attributes.locality {
                        if let address = item.attributes.address {
                            if let processedName = alreadyProcessedCities["\(city) \(address)"] {
                                let distanceValue = userLocation.distance(from: processedName)
                                distance = String(format: "%.2f", distanceValue / 1000) + " km"
                            }
                            do {
                                if let location = try await locationManager.findCoordinatesOfCityName(name: "\(city) \(address)") {
                                    let distanceValue = userLocation.distance(from: location)
                                    distance = String(format: "%.2f", distanceValue / 1000) + " km"
                                    alreadyProcessedCities[city] = location
                                }
                            } catch {
                                distance = "Brak odległości"
                            }
                        }
                    }
                }
                
                if let index = queueItems.firstIndex(where: { $0.id == item.id }) {
                    queueItems[index].distance = distance
                }
            }
        }
    }
}

