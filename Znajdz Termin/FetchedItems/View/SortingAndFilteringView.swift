//
//  SortingAndFilteringView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/07/2024.
//

import SwiftUI

struct SortingAndFilteringView: View {
    @Binding var selectedSorting: QuerySortingOptions
    @Binding var selectedFiltering: String
    @Binding var shouldShowNearVoivodeships: Bool
    @State var shouldShowNearVoivodeshipsButton: Bool
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .foregroundStyle(selectedSorting != QuerySortingOptions.date ? .green.opacity(0.25) : .gray.opacity(0.25))
                    
                    Menu {
                        Picker("Sortowanie", selection: $selectedSorting) {
                            ForEach(QuerySortingOptions.allCases, id: \.self) { sortingCase in
                                Text(sortingCase.description)
                            }
                        }
                        .tint(.primary)
                    } label: {
                        VStack {
                            Text("Sortuj według")
                                .font(.subheadline)
                            HStack {
                                Text(selectedSorting.description)
                                    .font(.caption)
                                Image(systemName: "chevron.down")
                                    .accessibilityHidden(true)
                            }
                            .accessibilityLabel("Wybrane sortowanie \(selectedSorting.description)")
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding()
                }
                
                
                if shouldShowNearVoivodeshipsButton {
                    FilterOptionView(filterOption: $shouldShowNearVoivodeships, filterOptionText: "Pokaż wyniki z przyległych województw")
                        .accessibilityLabel("Pokaż pobliskie województwa")
                        .accessibilityAddTraits(.isButton)
                }
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    SortingAndFilteringView(selectedSorting: .constant(.date), selectedFiltering: .constant("Filter"), shouldShowNearVoivodeships: .constant(true), shouldShowNearVoivodeshipsButton: true)
}
