//
//  MainView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 26/06/2024.
//

import SwiftUI

struct MainView: View {
    @State private var isLoading = true
    var body: some View {
        NavigationStack {
            if isLoading {
                LoadingView(isLoading: $isLoading)
            } else {
                HomeView()
            }
        }
    }
}

#Preview {
    MainView()
}
