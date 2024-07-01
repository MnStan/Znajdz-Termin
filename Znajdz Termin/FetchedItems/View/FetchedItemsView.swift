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
    @State private var selectedItemID: String? = nil
    @Namespace var itemsNamespace
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.itemsArray, id: \.id) { item in
                        GroupBox {
                            ZStack {
                                if selectedItemID != item.id {
                                    ItemView(itemsNamespace: itemsNamespace, dataElement: item)
                                } else {
                                    DetailItemView(itemsNamespace: itemsNamespace, dataElement: item)
                                        .id(item.id)
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.5, bounce: 0.3)) {
                                selectedItemID = item.id
                                value.scrollTo(item.id, anchor: .top)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                    }
                    .shadow(color: colorScheme == .light ? .gray.opacity(0.25) : Color.clear, radius: 5, y: 5)
                    .frame(maxWidth: .infinity)
                    
                    if viewModel.canLoadMore() {
                        ProgressView()
                            .task {
                                await viewModel.fetchNextPage()
                            }
                    }
                }
            }
        }
        .background(.blue.opacity(0.1))
        .onDisappear {
            viewModel.resetNetworkManager()
        }
    }
}

#Preview {
    FetchedItemsView()
}
