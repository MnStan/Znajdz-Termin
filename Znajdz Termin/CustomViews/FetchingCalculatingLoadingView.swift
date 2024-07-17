//
//  FetchingCalculatingLoadingView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 16/07/2024.
//

import SwiftUI

struct FetchingCalculatingLoadingView: View {
    @State private var animateGradient = false
    @State private var animateGradientPhase: CGFloat = 0
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [.clear, .gray.opacity(0.8)],
                           startPoint: UnitPoint(x: 0 - animateGradientPhase, y: 0),
                           endPoint: UnitPoint(x: 0 + animateGradientPhase, y: 0))
            .ignoresSafeArea()
            .onAppear {
                withAnimation(.linear(duration: 1).repeatForever(autoreverses: true)) {
                    animateGradientPhase = 1
                }
            }
            
            Text("Ładowanie")
                .padding()
        }
        .background(.ultraThinMaterial)
        .onAppear {
            animateGradient.toggle()
        }
    }
}

#Preview {
    FetchingCalculatingLoadingView()
}
