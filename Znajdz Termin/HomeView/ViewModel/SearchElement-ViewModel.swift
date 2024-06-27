//
//  SearchElement-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 24/06/2024.
//

import Foundation
import Combine

extension SearchElementView {
    
    @MainActor
    class ViewModel: ObservableObject {
        private let networkManager = NetworkManager.shared
        private let locationManager = AppLocationManager.shared
        @Published var benefitsArray: [String] = []
        private var cancellables = Set<AnyCancellable>()
        
        init() {
            networkManager.$benefitsDataArray
                .receive(on: DispatchQueue.main)
                .sink { [weak self] array in
                    self?.benefitsArray = array
                }
                .store(in: &self.cancellables)
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
        
        func getVoivodeshipNumber(selectedVoivodeship: String) -> String? {
            Voivodeship.allCases.first { $0.displayName == selectedVoivodeship }?.rawValue
        }
        
        func fetchDates(benefit: String, caseNumber: Int, province: String) {
            Task {
                await networkManager.fetchDates(benefitName: benefit, caseNumber: caseNumber ,province: province)
            }
        }
    }
}
