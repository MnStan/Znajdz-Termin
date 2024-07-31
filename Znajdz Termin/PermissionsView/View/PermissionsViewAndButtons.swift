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
    @Environment(\.scenePhase) private var scenePhase
    
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
                    withAnimation(.spring(.bouncy, blendDuration: 1)) {
                        pageIndex += 1
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(Capsule())
                
            } else {
                Button("Udziel zgód", systemImage: "checkmark.circle.fill") {
                    viewModel.requestPermissions { location, calendar  in
                        if calendar, location {
                            permissions = .full
                            permissionAsked = true
                            isFirstLaunch = false
                        } else if calendar, !location {
                            permissions = .onlyCalendar
                            showingAlert = true
                        } else if !calendar, location {
                            permissions = .onlyLocalization
                            showingAlert = true
                        } else {
                            showingAlert = true
                        }
                    }
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(Capsule())
                
                .alert(Text("Zgody zostały odrzucone"), isPresented: $showingAlert) {
                    Button("Udziel zgód") {
                        openSettings()
                    }
                    
                    Button("OK", role: .cancel) {
                        permissionAsked = true
                        isFirstLaunch = false
                    }
                } message: {
                    switch permissions {
                    case .onlyLocalization:
                        Text("Aplikacja nie będzie mogła dodać ani pobrać wydarzeń z kalendarza.\n\nMożesz zmienić dostęp do kalendarza w ustawieniach.")
                    case .onlyCalendar:
                        Text("Aplikacja nie będzie mogła pobrać lokalizacji.\n\nPodpowiedzi dotyczące województwa będą niedostępne.\n\nMożesz zmienić dostęp do lokalizacji w ustawieniach.")
                    default:
                        Text("Aplikacja nie będzie mogła pobrać lokalizacji. Podpowiedzi dotyczące województwa będą niedostępne.\n\nAplikacja nie będzie mogła dodać ani pobrać wydarzeń z kalendarza.\n\nMożesz zmienić dostęp do lokalizacji i kalendarza w ustawieniach.")
                    }
                }

            }
        }
        .onChange(of: scenePhase) { oldValue, newValue in
            if newValue == .inactive && oldValue == .background {
                permissionAsked = true
                isFirstLaunch = false
            }
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}

#Preview {
    PermissionViewAndButtons()
}
