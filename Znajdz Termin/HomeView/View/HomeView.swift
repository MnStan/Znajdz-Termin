//
//  HomeView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 16/06/2024.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationManager: AppLocationManager
    @EnvironmentObject var networkManager: NetworkManager
    @State var search = ""
    @State var isSearchFocused: Bool = false
    @FocusState var textViewFocus: Bool
    @State var isSearchViewEditing = false
    
    var body: some View {
        ScrollView {
            SearchElementView(locationManager: locationManager, networkManager: networkManager, searchText: $search, isSearchFocused: $isSearchFocused, textViewFocus: $textViewFocus, isSearchViewEditing: $isSearchViewEditing)
                .padding()
            
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
        }
        .navigationTitle("Dzień dobry")
        .shadow()
        .navigationBarTitleDisplayMode(.large)
        
        .background(.blue.opacity(0.1))
        
        .onTapGesture {
            withAnimation(.spring(.bouncy)) {
                textViewFocus = false
                isSearchFocused = false
            }
        }
        
        Button("Get all") {
            Task {
//                await NetworkManager.shared.fetchDates(benefitName: "poradnia",province: "06", onlyOnePage: false)
            }
        }
    }
}

#Preview {
    HomeView()
}
