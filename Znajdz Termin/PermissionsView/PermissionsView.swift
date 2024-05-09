//
//  PermissionsView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 08/05/2024.
//

import SwiftUI

struct PermissionsView: View {
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    
    var body: some View {
        if verticalSizeClass == .compact {
            HStack() {
                PermissionViewAndButtons()
            }
        } else {
            VStack() {
                PermissionViewAndButtons()
            }
        }
    }
}

#Preview {
    PermissionsView()
}
