//
//  QueueItem.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 02/07/2024.
//

import Foundation

struct QueueItem: Identifiable {    
    let queueResult: DataElement
    let id: String
    var distance: String
    var latitude: Double?
    var longitude: Double?
    
    var uniqueID: String {
        "\(id)-\(String(latitude ?? 0.0))-\(String(longitude ?? 0.0))"
    }
    
    init(queueResult: DataElement, distance: String, latitude: Double? = nil, longitude: Double? = nil) {
        self.queueResult = queueResult
        self.id = queueResult.id
        self.distance = distance
        self.latitude = latitude
        self.longitude = longitude
    }
}
