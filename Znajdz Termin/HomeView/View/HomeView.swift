//
//  HomeView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 16/06/2024.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var locationManager: AppLocationManager
    @EnvironmentObject var networkManager: NetworkManager
    @State var search = ""
    @State var isSearchFocused: Bool = false
    @FocusState var textViewFocus: Bool
    @State var isSearchViewEditing = false
    
    @Query(sort: \SearchInput.creationDate, order: .reverse) var lastSearches: [SearchInput]
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                SearchElementView(locationManager: locationManager, networkManager: networkManager, searchText: $search, isSearchFocused: $isSearchFocused, textViewFocus: $textViewFocus, isSearchViewEditing: $isSearchViewEditing)
                    .padding()
                    .id("Search")
                
                Group {
                    GroupBox("Najpopularniejsze") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                            ForEach(PopularSearches().mostPopular, id: \.self) { popular in
                                Button {
                                    withAnimation(.spring(.bouncy)) {
                                        proxy.scrollTo("Search", anchor: .top)
                                        isSearchFocused = true
                                        search = popular.benefit
                                    }
                                } label: {
                                    HStack {
                                        Text(popular.benefit)
                                            .padding()
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                    }
                    .backgroundStyle(.regularMaterial)
                    .padding()
                    .accessibilityLabel("Najpopularniejsze wyszukiwania")
                    
                    GroupBox("Ostatnie wyszukiwania") {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: 300))]) {
                            ForEach(lastSearches.prefix(4), id: \.self) { searchItem in
                                Button {
                                    withAnimation(.spring(.bouncy)) {
                                        proxy.scrollTo("Search", anchor: .top)
                                        isSearchFocused = true
                                        search = searchItem.benefit
                                    }
                                } label: {
                                    HStack {
                                        Text(searchItem.benefit)
                                            .padding()                                   
                                            .multilineTextAlignment(.leading)
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right.circle")
                                    }
                                }
                                .foregroundStyle(.primary)
                            }
                        }
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
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SearchInput.self, configurations: config)
    
    for _ in 1..<10 {
        let search = SearchInput(benefit: "Poradnia traumatologii ruchu", voivodeshipNumber: "06", caseNumber: false, isForKids: false)
        container.mainContext.insert(search)
    }
    
    return HomeView()
        .environmentObject(AppLocationManager())
        .environmentObject(NetworkManager())
        .modelContainer(container)
}
