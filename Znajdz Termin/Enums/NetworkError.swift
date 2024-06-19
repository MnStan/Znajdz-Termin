//
//  NetworkError.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 19/06/2024.
//

import Foundation

enum NetworkError: Error, CustomStringConvertible {
    case badRequest
    case badJSON
    case invalidURL
    case fetchError
    
    var description: String {
        switch self {
        case .badRequest:
            return "Coś poszło nie tak. Zapytanie do serwera jest nieprawidłowe. Spróbuj ponownie lub skontaktuj się z nami."
        case .badJSON:
            return "Coś poszło nie tak. Odpowiedź serwera jest nieprawidłowa. Spróbuj ponownie lub skontaktuj się z nami."
        case .invalidURL:
            return "Coś poszło nie tak. Adres zapytania jest nieprawidłowy. Spróbuj ponownie lub skontaktuj się z nami."
        case .fetchError:
            return "Coś poszło nie tak. Pobieranie odpowiedzi z serwera się nie powiodło. Spróbuj ponownie lub skontaktuj się z nami."
        }
    }
}
