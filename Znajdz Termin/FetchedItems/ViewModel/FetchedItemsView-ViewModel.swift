//
//  FetchedItemsView-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import Foundation
import Combine

extension FetchedItemsView {
    
    class ViewModel: ObservableObject {
        private let networkManager = NetworkManager.shared
        @Published var itemsArray: [DataElement] = []
        private var cancellables = Set<AnyCancellable>()
        @Published var networkError: NetworkError?
        @Published var isNetworkWorkDone: Bool = false
        
        init() {
            networkManager.$datesDataArray
                .receive(on: DispatchQueue.main)
                .sink { [weak self] array in
                    self?.itemsArray = array
                }
                .store(in: &self.cancellables)
            
            networkManager.$networkError
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    self?.networkError = error
                }
                .store(in: &self.cancellables)
            
            networkManager.$canFetchMorePages
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
    }
}
