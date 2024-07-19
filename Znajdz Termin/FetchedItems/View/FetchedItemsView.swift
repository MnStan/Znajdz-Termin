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
    @Environment(\.accessibilityReduceMotion) var isReduceMotionEnabled
    
    @State var selectedSorting = QuerySortingOptions.date
    @State var selectedFiltering = ""
    @State var shouldShowNearVoivodeships = false
    @State var shouldShowSortingAndFiltering = false
    
    var searchInput: SearchInput
    
    init(locationManager: LocationManagerProtocol, networkManager: NetworkManager, selectedItemID: String? = nil, selectedSorting: QuerySortingOptions = QuerySortingOptions.date, searchInput: SearchInput) {
        self.selectedItemID = selectedItemID
        self.selectedSorting = selectedSorting
        self.searchInput = searchInput
        _viewModel = StateObject(wrappedValue: ViewModel(networkManager: networkManager, locationManager: locationManager))
    }
    
    var body: some View {
        ZStack(alignment: .top) {
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
                        }
                        
                        if viewModel.queueItems.isEmpty {
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
                            .accessibilityLabel("Trwa ładowanie")
                        } else {
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
                                    if isReduceMotionEnabled {
                                        selectedItemID = item.id
                                        value.scrollTo(item.id, anchor: .top)
                                        shouldShowSortingAndFiltering = false
                                    } else {
                                        withAnimation(.spring(duration: 0.5)) {
                                            selectedItemID = item.id
                                            value.scrollTo(item.id, anchor: .top)
                                            shouldShowSortingAndFiltering = false
                                        }
                                    }
                                }
                                .padding([.leading, .trailing])
                                .padding([.top, .bottom], 5)
                                .frame(maxWidth: .infinity)
                            }
                            .shadow()
                            .frame(maxWidth: .infinity)
                            
                            if !viewModel.isNetworkWorkDone {
                                ProgressView()
                                    .task {
                                        await viewModel.fetchNextPage()
                                    }
                            }
                        }
                    }
                }
            }
            .background(.blue.opacity(0.1))
            .onAppear {
                viewModel.fetchDates(searchInput: searchInput)
            }
            .onChange(of: selectedSorting) { oldValue, newValue in
                viewModel.sortItems(oldValue: oldValue, newValue: newValue)
            }
            .onChange(of: shouldShowNearVoivodeships, { oldValue, newValue in
                viewModel.fetchNearVoivodeshipsDates(searchInput: searchInput)
            })
            .navigationBarTitleDisplayMode(.inline)
            
            VStack {
                if shouldShowSortingAndFiltering {
                    VStack {
                        SortingAndFilteringView(selectedSorting: $selectedSorting, selectedFiltering: $selectedFiltering, shouldShowNearVoivodeships: $shouldShowNearVoivodeships)
                            .padding([.leading, .trailing])
                            .padding(.top, 10)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                    
                    .background(.ultraThinMaterial,
                                in: RoundedRectangle(cornerRadius: 15)
                    )
                }
                
                Spacer()
                
                if shouldShowNearVoivodeships && (viewModel.isCalculatingDistances || viewModel.fetchingNear) {
                    FetchingCalculatingLoadingView()
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .fixedSize(horizontal: true, vertical: true)
                        .offset(y: -100)
                }
            }

        }
        .toolbar {
            Button {
                if isReduceMotionEnabled {
                    shouldShowSortingAndFiltering.toggle()
                } else {
                    withAnimation(.spring(duration: 0.5)) {
                        shouldShowSortingAndFiltering.toggle()
                    }
                }
            } label: {
                Image(systemName: "gear")
            }
        }
    }
}

#Preview {
    FetchedItemsView(locationManager: AppLocationManager(), networkManager: NetworkManager(), searchInput: SearchInput(benefit: "orto", voivodeshipNumber: "06", caseNumber: false, isForKids: false))
}
