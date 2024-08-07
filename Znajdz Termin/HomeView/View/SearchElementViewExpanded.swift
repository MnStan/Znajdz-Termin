//
//  SearchElementViewExpanded.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 26/06/2024.
//

import SwiftUI

struct SearchElementViewExpanded: View {
    @EnvironmentObject var locationManager: AppLocationManager
    @EnvironmentObject var networkManager: NetworkManager
    @Environment(\.modelContext) var modelContext
    @Binding var searchText: String
    @Binding var isSearchFocused: Bool
    @Namespace var searchNamespace: Namespace.ID
    @FocusState.Binding var textViewFocus: Bool
    @StateObject var viewModel: SearchElementView.ViewModel
    @Binding var isSearchViewEditing: Bool
    @Binding var pickedVoivodeship: String
    @Binding var selectedIsForKids: Bool
    @Binding var selectedMedicalCase: Bool
    @State var shouldShowFetchedItemsView = false
    @State var shouldShowAlert = false
    @State var searchInput: SearchInput?
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .matchedGeometryEffect(id: "background", in: searchNamespace)
                .foregroundStyle(.regularMaterial)
                .accessibilityHidden(true)
                .ignoresSafeArea()
            
            VStack {
                searchField
                voivodeshipPicker
                toggles
                buttons
            }
            .padding()
            .onAppear {
                isSearchViewEditing = true
                if viewModel.checkPermissions() {
                    pickedVoivodeship = viewModel.getUserVoivodeship()
                }
            }
            .onDisappear {
                isSearchViewEditing = false
            }
        }
        .navigationBarBackButtonHidden()
        .onTapGesture {
            textViewFocus = false
        }
        .navigationDestination(isPresented: $shouldShowFetchedItemsView) {
            if let searchInput {
                FetchedItemsView(locationManager: locationManager, networkManager: networkManager, searchInput: searchInput, shouldShowNearVoivodeshipsButton: viewModel.checkIfUserSelectedOtherVoivodeship(selectedVoivodeship: pickedVoivodeship))
            }
        }
        .alert("Tekst wyszukiwania powinien mieć długość co najmniej 3 liter", isPresented: $shouldShowAlert) {
            Button("Ok", role: .cancel) { }
        }
    }
    
    @ViewBuilder
    private var searchField: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .accessibilityHidden(true)
                TextField("Szukaj", text: $searchText)
                    .multilineTextAlignment(.leading)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .focused($textViewFocus)
                    .onChange(of: searchText) { oldValue, newValue in
                        viewModel.checkNewValueInput(oldValue: oldValue, newValue: newValue)
                    }
                
                if searchText != "" {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "x.circle.fill")
                            .foregroundStyle(.gray)
                            .accessibilityLabel("Przycisk usuwania wprowadzonego tekstu")
                    }
                }
            }
            
            if let suggestion = viewModel.prepareSuggestionToView(searchText: searchText), viewModel.shouldShowHint {
                suggestionView(suggestion)
            }
        }
    }
    
    @ViewBuilder
    private func suggestionView(_ suggestion: String) -> some View {
        Group {
            Text("Podpowiedź:")
                .accessibilityHidden(true)
                .opacity(0.5)
            Button {
                searchText = suggestion
                textViewFocus = false
                viewModel.shouldShowHint = false
            } label: {
                Text(suggestion)
                    .multilineTextAlignment(.leading)
            }
            .accessibilityLabel("Podpowiedź \(suggestion) kliknij aby użyć podpowiedzi")
        }
        .accessibilityElement(children: .combine)
        .onAppear {
            UIAccessibility.post(notification: .announcement, argument: "Poniżej pojawiła się podpowiedź do twojego wyszukiwania")
        }
    }
    
    @ViewBuilder
    private var voivodeshipPicker: some View {
        if horizontalSizeClass == .compact && sizeCategory > .extraExtraExtraLarge {
            VStack {
                Text("Województwo")
                    .accessibilityHidden(true)
                
                Picker("Województwo", selection: $pickedVoivodeship) {
                    ForEach(Voivodeship.allCases, id: \.displayName) {
                        Text($0.displayName)
                    }
                }
                .dynamicTypeSize(...DynamicTypeSize.accessibility4)
                .tint(.primary)
            }
        } else {
            HStack {
                Text("Województwo")
                    .accessibilityHidden(true)
                
                Spacer()
                
                Picker("Województwo", selection: $pickedVoivodeship) {
                    ForEach(Voivodeship.allCases, id: \.displayName) {
                        Text($0.displayName)
                    }
                }
                .tint(.primary)
                .accessibilityLabel("Wybrane województwo \(pickedVoivodeship)")
            }
            .accessibilityElement(children: .combine)
        }
    }
    
    @ViewBuilder
    private var toggles: some View {
        Toggle(isOn: $selectedMedicalCase) {
            Text("Pilne")
        }
        
        Toggle(isOn: $selectedIsForKids) {
            Text("Dla dzieci")
        }
    }
    
    @ViewBuilder
    private var buttons: some View {
        Grid {
            GridRow {
                Button {
                    withAnimation(.spring(.bouncy, blendDuration: 1)) {
                        isSearchFocused = false
                        textViewFocus = false
                    }
                } label: {
                    Text("Zamknij")
                        .modifier(CustomButton(isCancel: true))
                }
                .foregroundStyle(.primary)
                
                Button {
                    if viewModel.checkTextCount(text: searchText) {
                        if let voivodeshipNumber = viewModel.getVoivodeshipNumber(selectedVoivodeship: pickedVoivodeship) {
                            searchInput = SearchInput(benefit: searchText, voivodeshipNumber: voivodeshipNumber, caseNumber: selectedMedicalCase, isForKids: selectedIsForKids)
                            if let toSave = searchInput {
                                modelContext.insert(toSave)
                            }
                            shouldShowFetchedItemsView = true
                        }
                    } else {
                        shouldShowAlert = true
                    }
                } label: {
                    Text("Szukaj")
                        .modifier(CustomButton(isCancel: false))
                }
                .foregroundStyle(.primary)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    func deleteDestinations() {
        do {
            try modelContext.delete(model: SearchInput.self, where: #Predicate { item in
                item.creationDate.timeIntervalSinceNow > 2
            })
        } catch {
            
        }
    }
}

#Preview {
    @FocusState var focus: Bool
    
    return SearchElementViewExpanded(searchText: .constant("Test"), isSearchFocused: .constant(true), textViewFocus: $focus, viewModel: SearchElementView.ViewModel(), isSearchViewEditing: .constant(true), pickedVoivodeship: .constant("małopolskie"), selectedIsForKids: .constant(false), selectedMedicalCase: .constant(false))
}
