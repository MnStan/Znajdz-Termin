//
//  MainView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 26/06/2024.
//

import SwiftUI

struct MainView: View {
    @StateObject var locationManager = AppLocationManager()
    @StateObject var networkManager = NetworkManager()
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
    }
}

#Preview {
    MainView()
}
