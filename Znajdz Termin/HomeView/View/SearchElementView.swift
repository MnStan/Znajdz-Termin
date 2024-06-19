//
//  SearchElement.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 18/06/2024.
//

import SwiftUI

struct SearchElementView: View {
    @Binding var searchText: String
    @Binding var isSearchFocused: Bool
    @Namespace var namespace
    @FocusState.Binding var textViewFocus: Bool
    
    var body: some View {
        ZStack {
            if !isSearchFocused {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .matchedGeometryEffect(id: "background", in: namespace)
                        .foregroundStyle(.ultraThickMaterial)
                    VStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            
                            TextField("Szukaj", text: $searchText)
                                .disabled(true)
                            
                        }
                    }
                    .padding()
                }
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .matchedGeometryEffect(id: "background", in: namespace)
                        .foregroundStyle(.thickMaterial)
                    VStack {
                        HStack {
                            Image(systemName: "magnifyingglass")
                            
                            TextField("Szukaj", text: $searchText)
                                .autocorrectionDisabled()
                                .focused($textViewFocus)
                        }
                        
                        HStack {
                            Text("Test owanie")
                            Text("Test owanie")
                        }
                        HStack {
                            Text("Test owanie")
                            Text("Test owanie")
                        }
                        HStack {
                            Text("Test owanie")
                            Text("Test owanie")
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
            }
        }
    }
}

#Preview {
    @FocusState var focus: Bool
    
    return SearchElementView(searchText: .constant(""), isSearchFocused: .constant(false), textViewFocus: $focus)
}
