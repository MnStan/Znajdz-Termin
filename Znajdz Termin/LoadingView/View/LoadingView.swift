//
//  LoadingView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 28/05/2024.
//

import SwiftUI



struct LoadingView: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotionEnabled
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    @StateObject private var viewModel: ViewModel
    @State private var scale: CGFloat = 1.0
    @State private var isSpinning = true
    @Binding var isLoading: Bool
    
    private var logoSize: CGFloat {
        verticalSizeClass == .compact && sizeCategory >= .accessibilityMedium && (viewModel.locationError != nil) ? 100 : 200
    }
    
    private var shouldShowTextInScrollView: Bool {
        verticalSizeClass == .compact && sizeCategory >= .accessibilityExtraLarge && (viewModel.locationError != nil) ? true : false
    }
    
    init(isLoading: Binding<Bool>, locationManager: any LocationManagerProtocol) {
        _isLoading = isLoading
        _viewModel = StateObject(wrappedValue: ViewModel(locationManager: locationManager))
    }
    
    var body: some View {
        let combinedBinding = Binding<Bool>(
            get: {
                if viewModel.locationError == nil && viewModel.locationWorkDone {
                    return true
                } else if viewModel.locationError == .authorizationDenied {
                    return true
                }
                return false
            },
            set: { _,_ in }
        )
        
            VStack {
                ZStack {
                    Heart()
                        .foregroundStyle(Color.gray)
                        .foregroundStyle(.thinMaterial)
                        .fadeAnimation()
                    
                    Heart()
                        .rotation3DEffect(
                            Angle(degrees: 180),
                            axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                        .foregroundStyle(.blue)
                        .foregroundStyle(.thinMaterial)
                        .fadeAnimation()
                }
                .frame(width: logoSize, height: logoSize)
                
                if let error = viewModel.locationError {
                    if shouldShowTextInScrollView {
                        ScrollView {
                            Text("\(error)")
                                .font(.headline)
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                    } else {
                        Text("\(error)")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                    
                    if error == .geocodeError {
                        Text("Spróbujemy ponownie za: \(viewModel.timeRemaining)")
                            .font(.caption)
                            .multilineTextAlignment(.center)
                            .padding()
                    }
                } else {
                    Text("Ładowanie...")
                        .padding(.top, 50)
                        .font(.title).bold()
                        .accessibilityLabel("Trwa ładowanie")
                    
                }
            }
            .accessibilityLabel("Dwukolorowe logo w kształcie serca trwa ładowanie")
            .onChange(of: viewModel.locationError, { oldValue, newValue in
                if newValue == .geocodeError {
                    viewModel.getNearVoivodeshipsAgain()
                }
            })
            .onChange(of: combinedBinding.wrappedValue, { oldValue, newValue in
                if newValue == true { isLoading = false }
            })
    }
}

#Preview {
    LoadingView(isLoading: .constant(true), locationManager: AppLocationManager())
}
