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
        
        init(locationManager: any LocationManagerProtocol = AppLocationManager(), calendarManager: EventStoreProtocol = AppCalendarEventManager.shared) {
            self.locationManager = locationManager as? AppLocationManager ?? AppLocationManager()
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
        
        deinit {
            cancellables.forEach { $0.cancel() }
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
        
        func getLocationAgain() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                self?.locationManager.clearData()
                self?.locationManager.getLocationAgain()
            }
        }
    }
}
