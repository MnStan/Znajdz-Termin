//
//  MainView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 26/06/2024.
//

import SwiftUI
import SwiftData

struct MainView: View {
    @StateObject var locationManager = AppLocationManager()
    @StateObject var networkManager = NetworkManager()
    @StateObject var calendarManager = AppCalendarEventManager()
    
    @State private var isLoading = true
    var body: some View {
        NavigationStack {
            if isLoading {
                LoadingView(isLoading: $isLoading, locationManager: locationManager)
            } else {
                HomeView()
            }
        }
        .environmentObject(locationManager)
        .environmentObject(networkManager)
        .environmentObject(calendarManager)
        .modelContainer(for: SearchInput.self)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: SearchInput.self, configurations: config)
    
    let search = SearchInput(benefit: "Poradnia ortopedyczna", voivodeshipNumber: "06", caseNumber: true, isForKids: true)
    return MainView()
        .modelContainer(container)
}
