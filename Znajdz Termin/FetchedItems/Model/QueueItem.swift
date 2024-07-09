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
    
    init(queueResult: DataElement, distance: String) {
        self.queueResult = queueResult
        self.id = queueResult.id
        self.distance = distance
    }
}
