//
//  LocationError.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 16/06/2024.
//

import Foundation

enum LocationError: Error, CustomStringConvertible {
    case localizationUnknown
    case authorizationDenied
    case networkError
    case geocodeError
    case custom(error: Error)
    
    var description: String {
        switch self {
        case .localizationUnknown:
            return "Coś poszło nie tak. Nie możemy odczytać Twojej lokalizacji. Spróbuj ponownie"
        case .authorizationDenied:
            return "Aplikacja nie ma uprawnień do pobierania lokalizacji. Możesz to zmienić w ustawieniach"
        case .networkError:
            return "Wystąpił błąd z połączeniem z internetem. Spróbuj ponownie"
        case .geocodeError:
            return "Wystąpił problem podczas pobierania okolicznych województw. Spróbuj ponownie"
        case .custom(let error):
            return "Błąd: \(error.localizedDescription)"
        }
    }
}
