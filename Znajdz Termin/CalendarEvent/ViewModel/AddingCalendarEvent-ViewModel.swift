//
//  AddingCalendarEvent-ViewModel.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 31/07/2024.
//

import Foundation
import EventKit
import Combine

extension AddingCalendarEventView {
    class ViewModel: ObservableObject {
        private let calendarManager: AppCalendarEventManager
        @Published var calendarError: CalendarError?
        private var cancellables = Set<AnyCancellable>()
        
        init(calendarManager: AppCalendarEventManager) {
            self.calendarManager = calendarManager
            
            calendarManager.$calendarError
                .receive(on: DispatchQueue.main)
                .sink { [weak self] error in
                    self?.calendarError = error
                }
                .store(in: &cancellables)
        }
        
        deinit {
            cancellables.forEach { $0.cancel() }
        }
        
        func createCalendarEvent(dataElement: QueueItem, notes: String, pickedDate: Date, durationTime: Int, pickedHour: String) {
            Task {
                var location: CLLocationCoordinate2D? = nil
                if let latitude = dataElement.latitude, let longitude = dataElement.longitude {
                    location = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                }
                
                let convertedHour = pickedHour.convertToDateTime()
                let startDate = pickedDate.combine(time: convertedHour ?? .now) ?? .now
                let endDate = startDate.addingTimeInterval(TimeInterval(durationTime * 60))
                
                await calendarManager.createCalendarEvent(
                    title: "Wizyta \(dataElement.queueResult.attributes.benefit ?? "")",
                    address: "\(dataElement.queueResult.attributes.locality ?? "") \(dataElement.queueResult.attributes.address ?? "")",
                    locationName: dataElement.queueResult.attributes.provider ?? "",
                    startDate: startDate,
                    endDate: endDate,
                    notes: notes,
                    location: location
                )
            }
        }
    }
}
