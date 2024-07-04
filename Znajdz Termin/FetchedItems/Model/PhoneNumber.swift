//
//  PhoneNumber.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 04/07/2024.
//

import Foundation

struct PhoneNumber: Identifiable {
    var id = UUID()
    let phoneNumber: String
    let urlPhoneNumber: URL
}
