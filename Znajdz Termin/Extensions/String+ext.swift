//
//  String+ext.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 01/08/2024.
//

import Foundation

extension String {
    func convertToDate() -> Date? {
        let dateFormat = "yyyy-MM-dd"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_PL_POSIX")

        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        return nil
    }
    
    func convertToDateTime() -> Date? {
        let dateFormat = "HH:mm"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = dateFormat
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale(identifier: "en_PL_POSIX")

        if let date = dateFormatter.date(from: self) {
            return date
        }
        
        return nil
    }
}
