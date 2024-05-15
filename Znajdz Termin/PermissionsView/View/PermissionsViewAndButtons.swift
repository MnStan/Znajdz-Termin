//
//  PermissionsViewAndButtons.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 09/05/2024.
//

import SwiftUI
import MapKit
import EventKit

struct PermissionViewAndButtons: View {
    @AppStorage("isFirstLaunch") var isFirstLaunch = true
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    
    @State private var pageIndex = 0
    @State var permissionAsked = false
    @State var showingAlert = false
    @State private var viewModel = ViewModel()
    @State private var permissions: Permissions = .none
    
    var body: some View {
        NavigationStack {
            TabView(selection: $pageIndex) {
                PermissionInfoView(systemImage: "location.circle.fill", informationText: "Potrzebujemy Twojej zgody na wykorzystanie lokalizacji by uzyskać podpowiedzi do wyszukiwań oraz do wyświetlania Twojej lokalizacji na mapie")
                    .tag(0)
                
                PermissionInfoView(systemImage: "calendar.circle.fill", informationText: "Potrzebujemy Twojej zgody na dostęp do kalendarza by umożliwić Ci dodawanie przypomnień o wizytach")
                    .tag(1)
            }
            .safeAreaPadding()
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            if pageIndex != 1 {
                Button("Dalej", systemImage: "arrow.right") {
                    withAnimation {
                        pageIndex += 1
                    }
                }
                .padding()
            } else {
                Button("Udziel zgód", systemImage: "checkmark.circle.fill") {
                    viewModel.requestPermissions { granted in
                        if granted {
                            permissionAsked = true
                            isFirstLaunch = false
                        } else {
                            showingAlert = true
                        }
                    }
                }
                .padding()

                .navigationDestination(isPresented: $permissionAsked) {
                    ContentView().navigationBarBackButtonHidden()
                }
                
                .alert(Text("Coś poszło nie tak"), isPresented: $showingAlert) {
                    Button("OK", role: .cancel) { }
                } message: {
                    Text("Prosimy spróbuj ponownie")
                }

            }
        }
    }
}

#Preview {
    PermissionViewAndButtons()
}
