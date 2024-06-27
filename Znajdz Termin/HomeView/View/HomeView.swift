//
//  HomeView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 16/06/2024.
//

import SwiftUI

struct HomeView: View {
    @State var search = ""
    @State var isSearchFocused: Bool = false
    @FocusState var textViewFocus: Bool
    @State var isSearchViewEditing = false
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollView {
            SearchElementView(searchText: $search, isSearchFocused: $isSearchFocused, textViewFocus: $textViewFocus, isSearchViewEditing: $isSearchViewEditing)
                .padding()
                .onTapGesture {
                    withAnimation(.spring(.bouncy)) {
                        if isSearchViewEditing != true {
                            isSearchFocused = true
                            textViewFocus = true
                        }
                    }
                }
                .accessibilityLabel("Pole wyszukiwania")
            
            Group {
                GroupBox("Najpopularniejsze") {
                    Text("Test")
                    Text("Test")
                }
                .backgroundStyle(.regularMaterial)
                .padding()
                .accessibilityLabel("Najpopularniejsze wyszukiwania")
                
                GroupBox("Ostatnie wyszukiwania") {
                    Text("Test")
                    Text("Test")
                }
                .backgroundStyle(.regularMaterial)
                .padding()
                .accessibilityLabel("Ostatnie wyszukiwania")
            }
            
            List {
                ForEach(NetworkManager.shared.datesDataArray, id: \.id) { element in
                    Text(element.attributes.address ?? "coś")
                }
            }
        }
        .navigationTitle("Dzień dobry")
        .shadow(color: colorScheme == .light ? .gray.opacity(0.25) : Color.clear, radius: 5, y: 5)
        .navigationBarTitleDisplayMode(.large)
        
        .background(.blue.opacity(0.1))
        
        .onTapGesture {
            withAnimation(.spring(.bouncy, blendDuration: 1)) {
                textViewFocus = false
                isSearchFocused = false
            }
        }
    }
}

#Preview {
    HomeView()
}
