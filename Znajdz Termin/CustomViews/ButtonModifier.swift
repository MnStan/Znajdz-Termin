//
//  ButtonModifier.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 01/07/2024.
//

import SwiftUI

struct CustomButton: ViewModifier {
    var isCancel: Bool
    var shouldBeTransparent: Bool = true
    
    func body(content: Content) -> some View {
        content
            .padding()
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .frame(maxWidth: .infinity)
            .background(isCancel ? .red.opacity(shouldBeTransparent ? 0.25 : 1) : .gray.opacity(shouldBeTransparent ? 0.25 : 1))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(.primary)
    }
}
