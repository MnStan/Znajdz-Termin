//
//  FetchedItemsView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import SwiftUI
import Combine

struct FetchedItemsView: View {
    @StateObject private var viewModel = ViewModel()
    private let networkManager = NetworkManager.shared
    
    var body: some View {
        List {
            Text("Test")
            Text("\(viewModel.itemsArray.count)")
            ForEach(viewModel.itemsArray, id: \.id) { item in
                Text(item.attributes.provider ?? "Nic")
            }
        }
    }
}

#Preview {
    FetchedItemsView()
}
