//
//  QuerySortingOptions.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 08/07/2024.
//

import Foundation

enum QuerySortingOptions: CaseIterable ,CustomStringConvertible {
    case date
    case distance
    case awaiting
    
    var description: String {
        switch self {
        case .date:
            return "Data"
        case .distance:
            return "Odległość"
        case .awaiting:
            return "Liczba oczekujących"
        }
    }
}
