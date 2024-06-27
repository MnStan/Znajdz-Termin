//
//  SearchElement.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 18/06/2024.
//

import SwiftUI

struct SearchElementView: View {
    @Binding var searchText: String
    @Binding var isSearchFocused: Bool
    @Namespace var searchNamespace
    @FocusState.Binding var textViewFocus: Bool
    @StateObject private var viewModel = ViewModel()
    @State private var pickedVoivodeship: String = "dolnośląskie"
    @State private var selectedIsForKids = false
    @State private var selectedMedicalCase = false
    @Binding var isSearchViewEditing: Bool
    @State private var shouldShowHint = true
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityReduceMotion) var isReduceMotionEnabled
    
    var combinedBinding: Binding<Bool> {
        Binding(
            get: { self.isReduceMotionEnabled && self.isSearchFocused },
            set: { newValue in
                self.isSearchFocused = newValue
            }
        )
    }
    
    var body: some View {
        ZStack {
            if !isSearchFocused {
                SearchFieldView(searchText: $searchText)
            } else {
                if !isReduceMotionEnabled {
                    SearchElementViewExpanded(
                        searchText: $searchText,
                        isSearchFocused: $isSearchFocused,
                        searchNamespace: _searchNamespace,
                        textViewFocus: $textViewFocus,
                        viewModel: viewModel,
                        isSearchViewEditing: $isSearchViewEditing,
                        pickedVoivodeship: $pickedVoivodeship,
                        selectedIsForKids: $selectedIsForKids,
                        selectedMedicalCase: $selectedMedicalCase,
                        shouldShowHint: $shouldShowHint
                    )
                } else {
                    SearchFieldView(searchText: $searchText)
                }
            }
        }
        .navigationDestination(isPresented: combinedBinding) {
            SearchElementViewExpanded(
                searchText: $searchText,
                isSearchFocused: $isSearchFocused,
                searchNamespace: _searchNamespace,
                textViewFocus: $textViewFocus,
                viewModel: viewModel,
                isSearchViewEditing: $isSearchViewEditing,
                pickedVoivodeship: $pickedVoivodeship,
                selectedIsForKids: $selectedIsForKids,
                selectedMedicalCase: $selectedMedicalCase,
                shouldShowHint: $shouldShowHint
            )
        }
    }
}

#Preview {
    @FocusState var focus: Bool
    
    return SearchElementView(searchText: .constant(""), isSearchFocused: .constant(true), textViewFocus: $focus, isSearchViewEditing: .constant(true))
}
