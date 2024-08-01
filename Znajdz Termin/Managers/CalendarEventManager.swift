//
//  CalendarEventManager.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/05/2024.
//

import Foundation
import EventKit
import MapKit

protocol EventStoreProtocol {
    func requestAccess(to entityType: EKEntityType, completion: @escaping EKEventStoreRequestAccessCompletionHandler)
    func events(matching predicate: NSPredicate) -> [EKEvent]
    var authorizationStatus: EKAuthorizationStatus { get }
}

extension EKEventStore: EventStoreProtocol {
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
}

class AppCalendarEventManager: EventStoreProtocol, ObservableObject {
    @Published var calendarError: CalendarError?
    
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    static let shared: EventStoreProtocol = AppCalendarEventManager(eventStore: EKEventStore())
    private var eventStore: EKEventStore
    
    init(eventStore: EKEventStore = EKEventStore()) {
        self.eventStore = eventStore
    }
    
    static func authorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    func requestAccess(to entityType: EKEntityType, completion: @escaping EKEventStoreRequestAccessCompletionHandler) {
        eventStore.requestFullAccessToEvents { granted, error in
            completion(granted, error)
        }
    }
    
    func checkAccessToCalendar() -> Bool {
        switch authorizationStatus {
        case .notDetermined:
            false
        case .restricted:
            false
        case .denied:
            false
        case .fullAccess:
            true
        case .writeOnly:
            true
        case .authorized:
            true
        @unknown default:
            false
        }
    }

    func events(matching predicate: NSPredicate) -> [EKEvent] {
        return []
    }
    
    func createCalendarEvent(title: String, address: String, locationName: String, startDate: Date, endDate: Date, notes: String?, location: CLLocationCoordinate2D?) async {
        if checkAccessToCalendar() {
            let event = EKEvent(eventStore: eventStore)
            
            event.title = title
            event.startDate = startDate
            event.endDate = endDate
            
            if let notes = notes {
                event.notes = notes
            }
            
            if let location = location {
                let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: location))
                mapItem.name = locationName
                event.structuredLocation = EKStructuredLocation(mapItem: mapItem)
                event.structuredLocation?.title = address
            }
            
            event.calendar = eventStore.defaultCalendarForNewEvents
            
            do {
                try self.eventStore.save(event, span: .thisEvent)
            } catch {
                calendarError = .errorDuringSaving
            }
        } else {
            calendarError = .noAccess
        }
    }
}
