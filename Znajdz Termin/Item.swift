//
//  Item.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 08/05/2024.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
