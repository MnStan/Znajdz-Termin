//
//  FetchedItemsView-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import Foundation
import Combine

extension FetchedItemsView {
    
    @MainActor
    class ViewModel: ObservableObject {
        private let networkManager = NetworkManager.shared
        @Published var itemsArray: [DataElement] = []
        private var cancellables = Set<AnyCancellable>()
        
        init() {
            networkManager.$datesDataArray
                .receive(on: DispatchQueue.main)
                .sink { [weak self] array in
                    self?.itemsArray = array
                }
                .store(in: &self.cancellables)
        }
        
        deinit {
            cancellables.forEach { $0.cancel() }
        }
    }
}
