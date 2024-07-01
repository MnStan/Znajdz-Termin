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
        private let networkManager = NetworkManager.shared
        private let locationManager = AppLocationManager.shared
        @Published var shouldShowHint = false
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
        
        func getVoivodeshipNumber(selectedVoivodeship: String) -> String? {
            Voivodeship.allCases.first { $0.displayName == selectedVoivodeship }?.rawValue
        }
        
        func fetchDates(benefit: String, caseNumber: Int, isForKids: Bool, province: String) {
            Task {
                await networkManager.fetchDates(benefitName: benefit, caseNumber: caseNumber ,isForKids: isForKids, province: province, onlyOnePage: true)
            }
        }
    }
}
