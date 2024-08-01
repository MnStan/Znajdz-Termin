//
//  CalendarError.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 31/07/2024.
//

import Foundation

enum CalendarError: Error, CustomStringConvertible {
    case errorDuringSaving
    case noAccess
    
    var description: String {
        switch self {
        case .errorDuringSaving:
            "Wystąpił błąd podczas zapisywania wizyty.\nSpróbuj ponownie lub skontaktuj się z nami."
        case .noAccess:
            "Aplikacja nie ma dostępu do kalendarza."
        }
    }
}

