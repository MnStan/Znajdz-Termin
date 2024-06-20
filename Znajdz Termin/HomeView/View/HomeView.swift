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
    //    @Namespace var namespace
    @FocusState var textViewFocus: Bool
    
    var body: some View {
        NavigationStack {
            ScrollView {
                SearchElementView(searchText: $search, isSearchFocused: $isSearchFocused, textViewFocus: $textViewFocus)
                    .padding()
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            isSearchFocused = true
                            textViewFocus = true
                        }
                    }
                
                Group {
                    GroupBox("Najpopularniejsze") {
                        Text("Test")
                        Text("Test")
                    }
                    .backgroundStyle(.ultraThickMaterial)
                    .padding()
                    
                    GroupBox("Ostatnie wyszukiwania") {
                        Text("Test")
                        Text("Test")
                    }
                    .backgroundStyle(.ultraThickMaterial)
                    .padding()
                    
                    GroupBox("Ostatnie wyszukiwania") {
                        Text("Test")
                        Text("Test")
                    }
                    .backgroundStyle(.ultraThickMaterial)
                    .padding()
                }
            }
            .navigationTitle("Dzień dobry")
            .navigationBarTitleDisplayMode(.automatic)
        }
        .onTapGesture {
            withAnimation(.easeInOut) {
                textViewFocus = false
                isSearchFocused = false
            }
        }
    }
}

#Preview {
    HomeView()
}
