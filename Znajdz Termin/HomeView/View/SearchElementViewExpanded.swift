//
//  SearchElementViewExpanded.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 26/06/2024.
//

import SwiftUI

struct SearchElementViewExpanded: View {
    @Binding var searchText: String
    @Binding var isSearchFocused: Bool
    @Namespace var searchNamespace: Namespace.ID
    @FocusState.Binding var textViewFocus: Bool
    @ObservedObject var viewModel: SearchElementView.ViewModel
    @Binding var isSearchViewEditing: Bool
    @Binding var pickedVoivodeship: String
    @Binding var selectedIsForKids: Bool
    @Binding var selectedMedicalCase: Bool
    @Binding var shouldShowHint: Bool
    
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
                HStack(alignment: shouldShowHint ? .top : .center) {
                    Image(systemName: "magnifyingglass")
                    
                    VStack(alignment: .leading) {
                        TextField("Szukaj", text: $searchText, axis: .vertical)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($textViewFocus)
                            .onChange(of: searchText) { oldValue, newValue in
                                if newValue.count == 3 {
                                    viewModel.fetchBenefitsNames(for: newValue)
                                }
                                
                                if newValue.count >= 3 {
                                    if newValue.count - oldValue.count == 1 {
                                        shouldShowHint = true
                                    }
                                } else {
                                    viewModel.clearBenefitsArray()
                                }
                            }
                        
                        
                        if let suggestion = viewModel.prepareSuggestionToView(searchText: searchText), shouldShowHint {
                            Text("Podpowiedź:")
                                .opacity(0.5)
                            Button(suggestion) {
                                searchText = suggestion
                                textViewFocus = false
                                shouldShowHint = false
                            }
                            .multilineTextAlignment(.leading)
                        }
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
                .padding()
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.black, lineWidth: 1)
                        .matchedGeometryEffect(id: "border", in: searchNamespace)
                )
                .accessibilityHidden(true)
                
                VStack {
                    if horizontalSizeClass == .compact && sizeCategory > .extraExtraExtraLarge {
                        VStack {
                            Text("Województwo")
                            
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
                            
                            Spacer()
                            
                            Picker("Województwo", selection: $pickedVoivodeship) {
                                ForEach(Voivodeship.allCases, id: \.displayName) {
                                    Text($0.displayName)
                                }
                            }
                            .tint(.primary)
                        }
                    }
                    
                    Toggle(isOn: $selectedMedicalCase) {
                        Text("Pilne")
                    }
                    
                    Toggle(isOn: $selectedIsForKids) {
                        Text("Dla dzieci")
                    }
                    
                    Spacer()
                    
                    Grid {
                        GridRow {
                            Button {
                                withAnimation(.spring(.bouncy, blendDuration: 1)) {
                                    isSearchFocused = false
                                }
                            } label: {
                                Text("Zamknij")
                                    .padding()
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                                    .frame(maxWidth: .infinity)
                                    .background(.red.opacity(0.25))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .foregroundStyle(.primary)
                            
                            Button {
                                
                            } label: {
                                Text("Szukaj")
                                    .padding()
                                    .dynamicTypeSize(...DynamicTypeSize.accessibility1)
                                    .frame(maxWidth: .infinity)
                                    .background(.gray.opacity(0.25))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                            }
                            .foregroundStyle(.primary)

                        }
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }
                Spacer()
            }
            .padding()
            .onAppear {
                isSearchViewEditing = true
                pickedVoivodeship = viewModel.getUserVoivodeship()
            }
            .onDisappear {
                isSearchViewEditing = false
            }
        }
        .navigationBarBackButtonHidden()
        .onTapGesture {
            textViewFocus = false
        }
    }
}

#Preview {
    @FocusState var focus: Bool
    
    return SearchElementViewExpanded(searchText: .constant("Test"), isSearchFocused: .constant(true), textViewFocus: $focus, viewModel: SearchElementView.ViewModel(), isSearchViewEditing: .constant(true), pickedVoivodeship: .constant("małopolskie"), selectedIsForKids: .constant(false), selectedMedicalCase: .constant(false), shouldShowHint: .constant(false))
}
