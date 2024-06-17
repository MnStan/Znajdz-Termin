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
        @Published var timeRemaining = 60
        private var cancellables = Set<AnyCancellable>()
        private var timerCancellable: AnyCancellable?
        
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
        
        func startTimer() {
            timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { [weak self] _ in
                    self?.updateTimer()
                }
        }
        
        private func updateTimer() {
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
        }
        
        func stopTimer() {
            timerCancellable?.cancel()
            timerCancellable = nil
        }
        
        func getNearVoivodeshipsAgain() {
            timeRemaining = 60
            startTimer()
            DispatchQueue.main.asyncAfter(deadline: .now() + 60) { [weak self] in
                self?.locationManager.clearData()
                self?.locationManager.getLocationAgain()
                self?.stopTimer()
            }
        }
    }
}
