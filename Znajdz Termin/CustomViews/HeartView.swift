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

    path.move(to: CGPoint(x: rect.midX, y: rect.maxY ))

      path.addCurve(
        to: CGPoint(x: rect.midX, y: rect.minY + 100),
        control1:CGPoint(x: rect.minX - 65, y: rect.minY + 100),
        control2: CGPoint(x: rect.midX - 15, y: rect.minY + 25)
      )
      
      path.move(to: CGPoint(x: rect.midX - 15, y: rect.minY + 25))
      path.addLine(to: CGPoint(x: rect.midX - 25, y: rect.midY + 50))
    
     return path
  }
}
