//
//  SearchFieldView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import SwiftUI

struct SearchFieldView: View {
    @Namespace var searchNamespace: Namespace.ID
    @Binding var searchText: String
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .matchedGeometryEffect(id: "background", in: searchNamespace)
                .foregroundStyle(.regularMaterial)
                .accessibilityHidden(true)
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .accessibilityLabel("Ikona lupy")
                    
                    TextField("Szukaj", text: $searchText)
                        .disabled(true)
                    
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 0)
                        .matchedGeometryEffect(id: "border", in: searchNamespace)
                )
                .accessibilityHidden(true)
            }
            .padding()
        }
    }
}

#Preview {
    return SearchFieldView(searchText: .constant(""))
}
