//
//  ShadowModifier.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 01/07/2024.
//

import SwiftUI

struct ShadowModifier: ViewModifier {
    @Environment(\.colorScheme) var colorScheme
    
    func body(content: Content) -> some View {
        content
            .shadow(color: colorScheme == .light ? .gray.opacity(0.25) : Color.clear, radius: 5, y: 5)
    }
}

extension View {
    func shadow() -> some View {
        modifier(ShadowModifier())
    }
}
