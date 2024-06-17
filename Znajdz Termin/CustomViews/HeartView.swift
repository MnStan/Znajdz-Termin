//
//  HeartView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 11/06/2024.
//

import SwiftUI

struct Heart : Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let scaleX = rect.width / 200
        let scaleY = rect.height / 200
        
        path.move(to: CGPoint(x: rect.midX, y: rect.maxY ))
        
        path.addCurve(
            to: CGPoint(x: rect.midX, y: rect.minY + 100 * scaleY),
            control1:CGPoint(x: rect.minX - 65 * scaleX, y: rect.minY + 100 * scaleY),
            control2: CGPoint(x: rect.midX - 15 * scaleX, y: rect.minY + 25 * scaleY)
        )
        
        path.move(to: CGPoint(x: rect.midX - 15 * scaleX, y: rect.minY + 25 * scaleY))
        path.addLine(to: CGPoint(x: rect.midX - 25 * scaleX, y: rect.midY + 50 * scaleY))
        
        return path
    }
}
