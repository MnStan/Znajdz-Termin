//
//  FetchedItemsView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import SwiftUI
import Combine

struct FetchedItemsView: View {
    @EnvironmentObject var locationManager: AppLocationManager
    @EnvironmentObject var networkManager: NetworkManager
    @StateObject private var viewModel: FetchedItemsView.ViewModel
    @State private var selectedItemID: String? = nil
    @Namespace var itemsNamespace
    @Environment(\.dismiss) var dismiss
    
    @State var selectedSorting = QuerySortingOptions.date
    
    init(locationManager: any LocationManagerProtocol, networkManager: NetworkManager, selectedItemID: String? = nil, selectedSorting: QuerySortingOptions = QuerySortingOptions.date) {
        self.selectedItemID = selectedItemID
        self.selectedSorting = selectedSorting
        _viewModel = StateObject(wrappedValue: ViewModel(networkManager: networkManager, locationManager: locationManager))
    }
    
    var body: some View {
        ScrollViewReader { value in
            ScrollView {
                LazyVStack {
                    if let error = viewModel.networkError {
                        GroupBox {
                            ContentUnavailableView {
                                Image(systemName: "exclamationmark.triangle")
                                Text("Wystąpił błąd")
                            } description: {
                                Text(error.description)
                            } actions: {
                                Button("Spróbuj ponownie") {
                                    dismiss()
                                }
                                .modifier(CustomButton(isCancel: false))
                            }
                        }
                        .padding()
                        .shadow()
                    }
                    
                    if viewModel.queueItems.isEmpty && viewModel.isNetworkWorkDone {
                        GroupBox {
                            ContentUnavailableView {
                                Image(systemName: "magnifyingglass")
                                    .padding(.bottom)
                                Text("Brak danych dla tego wyszukiwania")
                                    .padding(.bottom)
                            } actions: {
                                Button {
                                    dismiss()
                                } label: {
                                    Text("Spróbuj ponownie")
                                        .modifier(CustomButton(isCancel: false))
                                }
                                .foregroundStyle(.primary)
                            }
                        }
                        .padding()
                        .shadow()
                    } else if viewModel.queueItems.isEmpty {
                        VStack {
                            ZStack {
                                Heart()
                                    .foregroundStyle(Color.gray)
                                    .foregroundStyle(.thinMaterial)
                                    .fadeAnimation()
                                
                                Heart()
                                    .rotation3DEffect(
                                        Angle(degrees: 180),
                                        axis: (x: 0.0, y: 1.0, z: 0.0)
                                    )
                                    .foregroundStyle(.blue)
                                    .foregroundStyle(.thinMaterial)
                                    .fadeAnimation()
                            }
                            .frame(width: 100, height: 100)
                            .accessibilityLabel("Dwukolorowe logo w kształcie serca")
                            
                            Text("Ładowanie...")
                                .padding(.top, 50)
                                .font(.title).bold()
                                .accessibilityLabel("Trwa ładowanie")
                        }
                    }
                    
                    ForEach(viewModel.queueItems, id: \.id) { item in
                        GroupBox {
                            ZStack {
                                if selectedItemID != item.id {
                                    ItemView(itemsNamespace: itemsNamespace, dataElement: item)
                                } else {
                                    DetailItemView(itemsNamespace: itemsNamespace, dataElement: item, selectedItemID: $selectedItemID)
                                        .id(item.id)
                                }
                            }
                        }
                        .onTapGesture {
                            withAnimation(.spring(duration: 0.5)) {
                                selectedItemID = item.id
                                value.scrollTo(item.id, anchor: .top)
                            }
                        }
                        .padding([.leading, .trailing])
                        .padding([.top, .bottom], 5)
                        .frame(maxWidth: .infinity)
                    }
                    .shadow()
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
            viewModel.cancelCalculateDistances()
        }
        .toolbar {
            Menu {
                Section("Sortowanie") {
                    Picker(selection: $selectedSorting) {
                        ForEach(QuerySortingOptions.allCases, id: \.self) { item in
                            Text(item.description)
                        }
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            } label: {
                Image(systemName: "gear")
            }
        }
        .onChange(of: selectedSorting) { oldValue, newValue in
            viewModel.sortItems(oldValue: oldValue, newValue: newValue)
        }
    }
}

#Preview {
    FetchedItemsView(locationManager: AppLocationManager(), networkManager: NetworkManager())
}
