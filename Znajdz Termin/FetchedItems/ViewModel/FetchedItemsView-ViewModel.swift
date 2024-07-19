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
    class ViewModel: ObservableObject {
        let networkManager: any NetworkManagerProtocol
        var locationManager: any LocationManagerProtocol
        @Published var queueItems: [QueueItem] = []
        private var initialQueueItems: [QueueItem] = []
        private var initialQueueItemsNear: [QueueItem] = []
        private var cancellables = Set<AnyCancellable>()
        @Published var networkError: NetworkError?
        @Published var isNetworkWorkDone: Bool = false
        var processedItemIDs: Set<String> = []
        @Published var findingCoordinatesError: Bool = false
        @Published var locationError: LocationError?
        private let processingSemaphore = DispatchSemaphore(value: 1)
        private var nearFetched = false
        private var showingNearItems = false
        @Published var isCalculatingDistances: Bool = false
        private var sortingOption: QuerySortingOptions = .date
        @Published var fetchingNear: Bool = false
        private let dateFormatter = DateFormatter()
        
        private var currentTasks: [UUID: Task<Void, Never>] = [:]
        
        @MainActor
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
            
            networkManager.datesNearDataArrayPublisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self] array in
                    self?.processNewItemsNear(newItems: array)
                }
                .store(in: &cancellables)
        }
        
        deinit {
            cleanup()
        }
        
        func cleanup() {
            cancellables.forEach { $0.cancel() }
            cancellables.removeAll()
            currentTasks.values.forEach { $0.cancel() }
            currentTasks.removeAll()
            networkManager.resetNetworkFetchingDates()
        }
        
        func fetchNextPage() async {
            await networkManager.fetchMoreDates()
        }
        
        func resetNetworkManager() {
            networkManager.resetNetworkFetchingDates()
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
            
            DispatchQueue.main.async {
                self.queueItems.append(contentsOf: newQueueItems)
            }
            
            calculateDistances(for: newItemsToProcess)
        }
        
        func processNewItemsNear(newItems: [DataElement]) {
            let newItemsToProcess = newItems.filter { !processedItemIDs.contains($0.id) }
            processedItemIDs.formUnion(newItemsToProcess.map { $0.id })
            
            let newQueueItems = newItemsToProcess.compactMap { item -> QueueItem? in
                guard queueItems.firstIndex(where: { $0.id == item.id }) == nil else {
                    return nil
                }
                let initialDistance = calculateInitialDistance(for: item)
                return QueueItem(queueResult: item, distance: initialDistance)
            }
            
            DispatchQueue.main.async {
                self.queueItems.append(contentsOf: newQueueItems)
            }
        }
        
        private func calculateInitialDistance(for item: DataElement) -> String {
            guard let userLocation = locationManager.location,
                  let latitude = item.attributes.latitude,
                  let longitude = item.attributes.longitude else {
                return "Obliczanie..."
            }
            
            let itemLocation = CLLocation(latitude: latitude, longitude: longitude)
            if let distanceValue = self.locationManager.calculateDistanceFromPoint(to: itemLocation) {
                return String(format: "%.2f km", distanceValue / 1000)
            }
            
            return "Obliczanie..."
        }
        
        func calculateDistances(for itemsToProcess: [DataElement], isForUserVoivodeship: Bool = true) {
            guard !itemsToProcess.isEmpty else { return }
            
            isCalculatingDistances = true
            
            let taskID = UUID()
            let task = Task { [weak self] in
                guard let self = self, let userLocation = self.locationManager.location else { return }
                processingSemaphore.wait()
                
                defer {
                    processingSemaphore.signal()
                }
                
                for item in itemsToProcess {
                    if Task.isCancelled { return }
                    
                    let distance = await self.calculateDistance(for: item, userLocation: userLocation)
                    
                    if Task.isCancelled { return }
                    await MainActor.run { [weak self] in
                        if let index = self?.queueItems.firstIndex(where: { $0.id == item.id }) {
                            self?.queueItems[index].distance = distance
                        }
                    }
                }
                
                self.currentTasks[taskID] = nil
                
                await MainActor.run { [weak self] in
                    self?.isCalculatingDistances = false
                }
                
                if sortingOption != .date {
                    await performSorting(sortingOption: sortingOption)
                }
                
                
                if isForUserVoivodeship {
                    initialQueueItems = queueItems
                } else {
                    initialQueueItemsNear = queueItems
                }
            }
            
            currentTasks[taskID] = task
        }
        
        private func calculateDistance(for item: DataElement, userLocation: CLLocation) async -> String {
            var distance: String = "Obliczanie..."
            
            if let latitude = item.attributes.latitude, let longitude = item.attributes.longitude {
                let itemLocation = CLLocation(latitude: latitude, longitude: longitude)
                if let distanceValue = self.locationManager.calculateDistanceFromPoint(to: itemLocation) {
                    distance = String(format: "%.2f km", distanceValue / 1000)
                }
            } else if let city = item.attributes.locality, let address = item.attributes.address {
                let fullAddress = "\(city) \(address)"
                
                do {
                    if let location = try await self.locationManager.findCoordinatesOfCityName(name: fullAddress) {
                        if let distanceValue = self.locationManager.calculateDistanceFromPoint(to: location) {
                            distance = String(format: "%.2f km", distanceValue / 1000)
                        }
                    }
                } catch {
                    distance = "Brak odległości"
                    await MainActor.run { [weak self] in
                        self?.findingCoordinatesError = true
                    }
                }
                
            } else {
                distance = "Brak odległości"
            }
            
            return distance
        }
        
        func sortItems(oldValue: QuerySortingOptions, newValue: QuerySortingOptions, queryItems: [QueueItem]? = nil ) {
            guard oldValue != newValue else { return }
            
            let taskID = UUID()
            let task = Task { [weak self] in
                guard let self else { return }
                if self.networkManager.canFetchMorePages == true {
                    await self.networkManager.fetchAllRemainingDates()
                }
                
                self.currentTasks[taskID] = nil
                self.sortingOption = newValue
                await self.performSorting(sortingOption: newValue)
            }
            
            currentTasks[taskID] = task
        }
        
        func performSorting(sortingOption: QuerySortingOptions, queryItems: [QueueItem]? = nil) async {
            await MainActor.run { [weak self] in
                guard let self else { return }
                let itemsToSort = queryItems ?? self.queueItems
                switch sortingOption {
                case .date:
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    self.queueItems = itemsToSort.sorted(by: { item1, item2 in
                        let date1 = item1.queueResult.attributes.dates?.date
                        let date2 = item2.queueResult.attributes.dates?.date
                        
                        if date1 == nil && date2 == nil {
                            return false
                        } else if date1 == nil {
                            return false
                        } else if date2 == nil {
                            return true
                        }
                        
                        if let date1String = date1, let date2String = date2,
                           let date1 = self.dateFormatter.date(from: date1String),
                           let date2 = self.dateFormatter.date(from: date2String) {
                            return date1 < date2
                        }
                        
                        return false
                    })
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
        
        func getVoivodeshipNumber(selectedVoivodeship: String) -> String? {
            Voivodeship.allCases.first { $0.displayName == selectedVoivodeship }?.rawValue
        }
        
        func fetchNearVoivodeshipsDates(searchInput: SearchInput) {
            showingNearItems.toggle()
            
            let taskID = UUID()
            let task = Task { [weak self] in
                guard let self else { return }
                if !nearFetched {
                    await MainActor.run { [weak self] in
                        self?.fetchingNear = true
                    }
                    
                    nearFetched = true
                    
                    if networkManager.nextPageURL != nil {
                        await networkManager.fetchDates(benefitName: searchInput.benefit, nextPage: nil, caseNumber: searchInput.caseNumber ? 1 : 2, isForKids: searchInput.isForKids, province: searchInput.voivodeshipNumber, onlyOnePage: false, userVoivodeship: true)
                    }
                    
                    if Task.isCancelled { return }
                    
                    let nearVoivodeships = locationManager.nearVoivodeships
                    for voivodeship in nearVoivodeships {
                        if Task.isCancelled { return }
                        if let voivodeshipNumber = getVoivodeshipNumber(selectedVoivodeship: voivodeship.lowercased()) {
                            await networkManager.fetchDates(benefitName: searchInput.benefit, nextPage: nil, caseNumber: searchInput.caseNumber ? 2 : 1, isForKids: searchInput.isForKids, province: voivodeshipNumber, onlyOnePage: false, userVoivodeship: false)
                        }
                    }
                    
                    self.currentTasks[taskID] = nil
                    
                    let newItemsToProcess = queueItems.filter { !$0.distance.contains("km") }
                    let newDataElements = newItemsToProcess.map { $0.queueResult }
                    processedItemIDs.formUnion(newDataElements.map { $0.id })
                    
                    await MainActor.run { [weak self] in
                        self?.calculateDistances(for: newDataElements, isForUserVoivodeship: false)
                        self?.fetchingNear = false
                    }
                    
                    await performSorting(sortingOption: sortingOption)
                } else {
                    await MainActor.run { [weak self] in
                        guard let self else { return }
                        if self.showingNearItems {
                            self.queueItems = self.initialQueueItemsNear
                        } else {
                            self.queueItems = self.initialQueueItems
                        }
                    }
                    
                    await performSorting(sortingOption: sortingOption)
                }
            }
            
            currentTasks[taskID] = task
        }
        
        func fetchDates(searchInput: SearchInput) {
            let taskID = UUID()
            let task = Task { [weak self] in
                await self?.networkManager.fetchDates(benefitName: searchInput.benefit, nextPage: nil, caseNumber: searchInput.caseNumber ? 1 : 2, isForKids: searchInput.isForKids, province: searchInput.voivodeshipNumber, onlyOnePage: true, userVoivodeship: true)
                self?.currentTasks[taskID] = nil
            }
            
            currentTasks[taskID] = task
        }
    }
}

