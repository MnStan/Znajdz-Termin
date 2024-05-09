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
    @State private var pageIndex = 0
    @State var permissionAsked = false
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    private let locationManager = CLLocationManager()
    private let eventManager = EKEventStore()
    
    var body: some View {
        NavigationStack {
            TabView(selection: $pageIndex) {
                PermissionInfoView(systemImage: "location.circle.fill", informationText: "Potrzebujemy Twojej zgody na wykorzystanie lokalizacji by uzyskać podpowiedzi do wyszukiwań oraz do wyświetlania Twojej lokalizacji na mapie")
                    .tag(0)
                
                PermissionInfoView(systemImage: "calendar.circle.fill", informationText: "Potrzebujemy Twojej zgody na dostęp do kalendarza by umożliwić Ci dodawanie wydarzeń i wyświetlanie zapisanych wizyt")
                    .tag(1)
            }
            .safeAreaPadding()
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            
            Spacer()
            
            if pageIndex != 1 {
                Button("Dalej", systemImage: "arrow.right") {
                    withAnimation {
                        pageIndex += 1
                    }
                }
                .padding()
            } else {
                Button("Udziel zgód", systemImage: "checkmark.circle.fill") {
                    locationManager.requestWhenInUseAuthorization()
                    eventManager.requestFullAccessToEvents { granted, _ in
                        permissionAsked.toggle()
                        UserDefaults.standard.set(false, forKey: "FirstLaunch")
                    }
                }
                .padding()
                
                .navigationDestination(isPresented: $permissionAsked) {
                    ContentView().navigationBarBackButtonHidden()
                }
            }
        }
    }
}

#Preview {
    PermissionViewAndButtons()
}
