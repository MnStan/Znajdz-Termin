//
//  SearchInput.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/07/2024.
//

import Foundation
import SwiftData

@Model
class SearchInput {
    var benefit: String
    var voivodeshipNumber: String
    var caseNumber: Bool
    var isForKids: Bool
    var creationDate: Date
    
    init(benefit: String, voivodeshipNumber: String, caseNumber: Bool, isForKids: Bool) {
        self.benefit = benefit
        self.voivodeshipNumber = voivodeshipNumber
        self.caseNumber = caseNumber
        self.isForKids = isForKids
        self.creationDate = Date()
    }
}
