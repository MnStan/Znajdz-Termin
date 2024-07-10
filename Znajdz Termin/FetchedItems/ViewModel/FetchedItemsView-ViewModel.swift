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
        private let networkManager: any NetworkManagerProtocol
        private var locationManager: any LocationManagerProtocol
        @Published var itemsArray: [DataElement] = []
        @Published var queueItems: [QueueItem] = []
        var initialQueueItems: [QueueItem] = []
        private var cancellables = Set<AnyCancellable>()
        @Published var networkError: NetworkError?
        @Published var isNetworkWorkDone: Bool = false
        var processedItemIDs: Set<String> = []
        var alreadyProcessedCities: [String: CLLocation] = [:]
        @Published var findingCoordinatesError: Bool = false
        private var calculateDistancesTask: Task<Void, Never>?
        @Published var locationError: LocationError?
        
        init(networkManager: NetworkManagerProtocol, locationManager: LocationManagerProtocol) {
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
            
            locationManager.locationErrorPublished
                .receive(on: DispatchQueue.main)
                .sink { [weak self] locationError in
                    self?.locationError = locationError
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
        
        func resetLocationManager() {
            //            locationManager.resetTasks()
        }
        
        func processNewItems(newItems: [DataElement]) {
            let newItemsToProcess = newItems.filter { !processedItemIDs.contains($0.id) }
            processedItemIDs.formUnion(newItemsToProcess.map { $0.id })
            
            let newQueueItems = newItemsToProcess.compactMap { item -> QueueItem? in
                guard queueItems.firstIndex(where: { $0.id == item.id }) == nil else {
                    return nil
                }
                let initialDistance = calculateInitialDistance(for: item)
                return QueueItem(queueResult: item, distance: initialDistance)
            }
            
            queueItems.append(contentsOf: newQueueItems)
            
            calculateDistances(for: newItemsToProcess)
        }
        
        private func calculateInitialDistance(for item: DataElement) -> String {
            guard let userLocation = locationManager.location,
                  let latitude = item.attributes.latitude,
                  let longitude = item.attributes.longitude else {
                return "Obliczam..."
            }
            
            let itemLocation = CLLocation(latitude: latitude, longitude: longitude)
            let distanceValue = userLocation.distance(from: itemLocation)
            return String(format: "%.2f km", distanceValue / 1000)
        }
        
        func calculateDistances(for itemsToProcess: [DataElement]) {
            calculateDistancesTask = Task { [weak self] in
                guard let self = self, let userLocation = self.locationManager.location else { return }
                
                for item in itemsToProcess {
                    if Task.isCancelled { return }
                    
                    var distance: String = "Obliczam..."
                    
                    if let latitude = item.attributes.latitude, let longitude = item.attributes.longitude {
                        let itemLocation = CLLocation(latitude: latitude, longitude: longitude)
                        let distanceValue = userLocation.distance(from: itemLocation)
                        distance = String(format: "%.2f km", distanceValue / 1000)
                    } else if let city = item.attributes.locality, let address = item.attributes.address {
                        let fullAddress = "\(city) \(address)"
                        if let processedLocation = self.alreadyProcessedCities[fullAddress] {
                            let distanceValue = userLocation.distance(from: processedLocation)
                            distance = String(format: "%.2f km", distanceValue / 1000)
                        } else {
                            do {
                                if Task.isCancelled { return }
                                if let location = try await self.locationManager.findCoordinatesOfCityName(name: fullAddress) {
                                    let distanceValue = userLocation.distance(from: location)
                                    distance = String(format: "%.2f km", distanceValue / 1000)
                                    self.alreadyProcessedCities[fullAddress] = location
                                }
                            } catch {
                                distance = "Brak odległości"
                                self.findingCoordinatesError = true
                            }
                        }
                    }
                    
                    if Task.isCancelled { return }
                    
                    if let index = self.queueItems.firstIndex(where: { $0.id == item.id }) {
                        self.queueItems[index].distance = distance
                    }
                }
                
                initialQueueItems = queueItems
            }
        }
        
        func cancelCalculateDistances() {
            calculateDistancesTask?.cancel()
        }
        
        func sortItems(oldValue: QuerySortingOptions, newValue: QuerySortingOptions, queryItems: [QueueItem]? = nil ) {
            guard oldValue != newValue else { return }
            
            let itemsToSort = queryItems ?? queueItems
            
            switch newValue {
            case .date:
                self.queueItems = self.initialQueueItems
            case .distance:
                self.queueItems = itemsToSort.sorted  { item1, item2 in
                    let distance1 = Double(item1.distance.replacingOccurrences(of: " km", with: "")) ?? 0.0
                    let distance2 = Double(item2.distance.replacingOccurrences(of: " km", with: "")) ?? 0.0
                    return distance1 < distance2
                }
            case .awaiting:
                self.queueItems = itemsToSort.sorted  { item1, item2 in
                    if let awaiting1 = item1.queueResult.attributes.statistics?.providerData?.awaiting {
                        if let awaiting2 = item2.queueResult.attributes.statistics?.providerData?.awaiting {
                            return awaiting1 < awaiting2
                        }
                    }
                    
                    return false
                }
            }
        }
    }
}

