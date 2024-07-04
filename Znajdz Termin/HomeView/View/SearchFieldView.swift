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
                
            VStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .accessibilityHidden(true)
                    
                    TextField("Szukaj", text: $searchText)
                    
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 0)
                        .matchedGeometryEffect(id: "border", in: searchNamespace)
                )
            }
            .padding()
        }
    }
}

#Preview {
    return SearchFieldView(searchText: .constant(""))
}
