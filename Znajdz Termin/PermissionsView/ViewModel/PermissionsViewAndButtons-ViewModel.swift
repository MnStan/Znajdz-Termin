//
//  PermissionsViewAndButtons-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/05/2024.
//

import Foundation
import CoreLocation
import EventKit

extension PermissionViewAndButtons {
    
    @Observable
    class ViewModel {
        private let locationManager: LocationManagerProtocol
        private let calendarManager: EventStoreProtocol
        
        init(locationManager: LocationManagerProtocol = AppLocationManager.shared, calendarManager: EventStoreProtocol = AppCalendarEventManager.shared) {
            self.locationManager = locationManager
            self.calendarManager = calendarManager
        }
        
        private func requestLocationPermission() {
            locationManager.requestWhenInUseAuthorization()
        }
        
        private func requestCalendarPermission(_ completion: @escaping (Bool) -> Void) {
            calendarManager.requestAccess(to: EKEntityType.event) { granted, error in
                if error != nil {
                    completion(false)
                } else {
                    completion(granted)
                }
            }
        }
        
        func requestPermissions(_ completion: @escaping (Bool) -> Void) {
            requestLocationPermission()
            requestCalendarPermission { granted in
                completion(granted)
            }
        }
    }
}
