//
//  FilterOptionView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 10/07/2024.
//

import SwiftUI

struct FilterOptionView: View {
    @Binding var filterOption: Bool
    var filterOptionText: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15)
                .foregroundStyle(filterOption ? .green.opacity(0.25) : .gray.opacity(0.25))
            
            Text(filterOptionText)
                .padding()
        }
        .onTapGesture {
            filterOption.toggle()
        }
    }
}

#Preview {
    FilterOptionView(filterOption: .constant(true), filterOptionText: "Test Filter")
}
