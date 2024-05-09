//
//  Znajdz_TerminApp.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 08/05/2024.
//

import SwiftUI
import SwiftData

@main
struct Znajdz_TerminApp: App {
    @AppStorage("FirstLaunch") var isFirstLaunch = true
    
    var body: some Scene {
        WindowGroup {
            if isFirstLaunch {
                PermissionsView()
            } else {
                ContentView()
            }
        }
    }
}
