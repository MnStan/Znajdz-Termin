//
//  ButtonModifier.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 01/07/2024.
//

import SwiftUI

struct CustomButton: ViewModifier {
    var isCancel: Bool
    func body(content: Content) -> some View {
        content
            .padding()
            .dynamicTypeSize(...DynamicTypeSize.accessibility1)
            .frame(maxWidth: .infinity)
            .background(isCancel ? .red.opacity(0.25) : .gray.opacity(0.25))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .foregroundStyle(.primary)
    }
}
