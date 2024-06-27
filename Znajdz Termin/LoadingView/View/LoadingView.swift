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
    @StateObject private var viewModel = ViewModel()
    @State private var scale: CGFloat = 1.0
    @State private var isSpinning = true
    @State private var shouldShowNextScreenAfterError = false
    @Binding var isLoading: Bool
    
    private var logoSize: CGFloat {
        verticalSizeClass == .compact && sizeCategory >= .accessibilityMedium && (viewModel.locationError != nil) ? 100 : 200
    }
    
    private var shouldShowTextInScrollView: Bool {
        verticalSizeClass == .compact && sizeCategory >= .accessibilityExtraLarge && (viewModel.locationError != nil) ? true : false
    }
    
    var body: some View {
        var combinedBinding = Binding<Bool>(
            get: {
                if viewModel.locationError == nil && viewModel.locationWorkDone {
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
                .accessibilityLabel("Dwukolorowe logo w kształcie serca")
                
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
            .onChange(of: viewModel.locationError, { oldValue, newValue in
                if newValue == .geocodeError {
                    viewModel.getNearVoivodeshipsAgain()
                }
            })
            .onChange(of: combinedBinding.wrappedValue, { oldValue, newValue in
                if newValue == true { isLoading = false }
            })
            .navigationDestination(isPresented: combinedBinding) {
                HomeView().navigationBarBackButtonHidden()
            }
    }
}

struct FadeAnimation: ViewModifier {
    @Environment(\.accessibilityReduceMotion) var isReduceMotionEnabled
    func body(content: Content) -> some View {
        if !isReduceMotionEnabled {
            content
                .phaseAnimator([0.5, 0.75, 1]) { view, phase in
                    view
                        .scaleEffect(phase)
                        .opacity(phase == 1 ? 1 : 0)
                }
        } else {
            content
        }
    }
}

extension View {
    func fadeAnimation() -> some View {
        modifier(FadeAnimation())
    }
}

#Preview {
    LoadingView(isLoading: .constant(true))
}
