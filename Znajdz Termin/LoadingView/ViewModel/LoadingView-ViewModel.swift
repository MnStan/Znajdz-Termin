//
//  LoadingView-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 11/06/2024.
//

import Foundation
import CoreLocation

extension LoadingView {
    
    @Observable
    class ViewModel {
        private let locationManager: LocationManagerProtocol
        private let calendarManager: EventStoreProtocol
        
        init(locationManager: LocationManagerProtocol = AppLocationManager.shared, calendarManager: EventStoreProtocol = AppCalendarEventManager.shared) {
            self.locationManager = locationManager
            self.calendarManager = calendarManager
        }
    }
}
