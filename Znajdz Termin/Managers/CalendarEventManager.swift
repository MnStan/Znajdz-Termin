//
//  CalendarEventManager.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/05/2024.
//

import Foundation
import EventKit

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

class AppCalendarEventManager: EventStoreProtocol {
    var authorizationStatus: EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: EKEntityType.event)
    }
    
    static let shared: EventStoreProtocol = AppCalendarEventManager(eventStore: EKEventStore())
    private var eventStore: EKEventStore
    
    init(eventStore: EKEventStore) {
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

    func events(matching predicate: NSPredicate) -> [EKEvent] {
        return []
    }
}
