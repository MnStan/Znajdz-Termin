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
        private let locationManager: AppLocationManager
        private let calendarManager: EventStoreProtocol
        
        @Published var locationError: LocationError?
        @Published var locationWorkDone = false
        private var cancellables = Set<AnyCancellable>()
        
        init(locationManager: LocationManagerProtocol = AppLocationManager.shared, calendarManager: EventStoreProtocol = AppCalendarEventManager.shared) {
            self.locationManager = locationManager as! AppLocationManager
            self.calendarManager = calendarManager
            
            locationManager.locationErrorPublished
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    self?.locationError = error
                }
                .store(in: &cancellables)
            
            locationManager.locationWorkDone
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isDone in
                    self?.locationWorkDone = isDone
                }
                .store(in: &cancellables)
        }
    }
}
