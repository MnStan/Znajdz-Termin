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
                        HStack {
                            Text(selectedSorting.description)
                            Image(systemName: "chevron.down")
                        }
                    }
                    .foregroundStyle(.primary)
                    .padding()
                }
                
                FilterOptionView(filterOption: $shouldShowNearVoivodeships, filterOptionText: "Pobliskie województwa")
            }
        }
        .scrollIndicators(.hidden)
    }
}

#Preview {
    SortingAndFilteringView(selectedSorting: .constant(.date), selectedFiltering: .constant("Filter"), shouldShowNearVoivodeships: .constant(true))
}
