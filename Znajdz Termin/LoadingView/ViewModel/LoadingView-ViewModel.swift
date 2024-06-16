//
//  LoadingView-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 11/06/2024.
//

import Foundation
import Combine
import CoreLocation

extension LoadingView {
    
    class ViewModel: ObservableObject {
        private let locationManager: LocationManagerProtocol
        private let calendarManager: EventStoreProtocol
        
        @Published var locationError: LocationError?
        private var cancellables = Set<AnyCancellable>()
        
        init(locationManager: LocationManagerProtocol = AppLocationManager.shared, calendarManager: EventStoreProtocol = AppCalendarEventManager.shared) {
            self.locationManager = locationManager
            self.calendarManager = calendarManager
            
            locationManager.locationErrorPublished
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    self?.locationError = error
                }
                .store(in: &cancellables)
        }
    }
}
