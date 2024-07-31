//
//  SearchElement-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 24/06/2024.
//

import Foundation
import Combine

extension SearchElementView {
    
    class ViewModel: ObservableObject {
        private let networkManager: NetworkManager
        private let locationManager: AppLocationManager
        @Published var shouldShowHint = false
        @Published var benefitsArray: [String] = []
        private var cancellables = Set<AnyCancellable>()
        
        init(locationManager: any LocationManagerProtocol = AppLocationManager(), networkManager: NetworkManager = NetworkManager()) {
            self.locationManager = locationManager as? AppLocationManager ?? AppLocationManager()
            self.networkManager = networkManager
            
            networkManager.$benefitsDataArray
                .receive(on: DispatchQueue.main)
                .sink { [weak self] array in
                    self?.benefitsArray = array
                }
                .store(in: &self.cancellables)
        }
        
        func checkNewValueInput(oldValue: String, newValue: String) {
            if newValue.count == 3 {
                fetchBenefitsNames(for: newValue)
            }
            
            if newValue.count >= 3 {
                if newValue.count - oldValue.count == 1 {
                    shouldShowHint = true
                }
            } else {
                clearBenefitsArray()
            }
        }
        
        func checkTextCount(text: String) -> Bool {
            text.count >= 3
        }
        
        func fetchBenefitsNames(for benefit: String) {
            if benefitsArray.isEmpty {
                Task {
                    await networkManager.fetchBenefits(benefitName: benefit)
                }
            }
        }
        
        func clearBenefitsArray() {
            benefitsArray.removeAll()
        }
        
        func prepareSuggestionToView(searchText: String) -> String? {
            if let matchedSuggestion = benefitsArray.first(where: { $0.lowercased().contains(searchText) }) {
                return matchedSuggestion.lowercased()
            }
            
            return nil
        }
        
        func getUserVoivodeship() -> String {
            locationManager.voivodeship.lowercased()
        }
        
        func checkPermissions() -> Bool {
            locationManager.authorizationStatus == .authorizedAlways || locationManager.authorizationStatus == .authorizedWhenInUse
        }
        
        func getVoivodeshipNumber(selectedVoivodeship: String) -> String? {
            Voivodeship.allCases.first { $0.displayName == selectedVoivodeship }?.rawValue
        }
        
        func checkIfUserSelectedOtherVoivodeship(selectedVoivodeship: String) -> Bool {
            return getVoivodeshipNumber(selectedVoivodeship: selectedVoivodeship) == getVoivodeshipNumber(selectedVoivodeship: getUserVoivodeship())
        }
    }
}
