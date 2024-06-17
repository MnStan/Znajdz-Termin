//
//  LoadingView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 28/05/2024.
//

import SwiftUI



struct LoadingView: View {
    @StateObject private var viewModel = ViewModel()
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        let combinedBinding = Binding<Bool>(
              get: {
                  if viewModel.locationError == nil && viewModel.locationWorkDone {
                      return true
                  }
                  return false
              },
              set: { _,_ in }
          )

        
        NavigationStack {
            VStack {
                ZStack {
                    Heart()
                        .foregroundStyle(Color.gray)
                        .foregroundStyle(.thinMaterial)
                    
                    Heart()
                        .rotation3DEffect(
                            Angle(degrees: 180),
                            axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                        .foregroundStyle(.blue)
                        .foregroundStyle(.thinMaterial)
                }
                .frame(width: 200, height: 200)
                
                Text("Ładowanie...")
                    .padding(.top, 50)
                
                if let error = viewModel.locationError {
                    Text("\(error)")
                        .multilineTextAlignment(.center)
                    
                    if error == .geocodeError {
                        Text("\(viewModel.timeRemaining)")
                    }
                }
                
                Text("\(combinedBinding.wrappedValue)")
            }
            .onChange(of: viewModel.locationError, { oldValue, newValue in
                if newValue == .geocodeError {
                    viewModel.getNearVoivodeshipsAgain()
                }
            })
            .navigationDestination(isPresented: combinedBinding) {
                HomeView().navigationBarBackButtonHidden()
            }
        }
    }
}

#Preview {
    LoadingView()
}
