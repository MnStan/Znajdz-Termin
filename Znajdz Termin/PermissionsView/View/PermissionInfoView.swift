//
//  PermissionInfoView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 08/05/2024.
//

import SwiftUI

struct PermissionInfoView: View {
    var systemImage: String
    var informationText: String
    
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.accessibilityReduceMotion) var isReduceMotionEnabled
    
    private var imageSize: CGFloat {
        if verticalSizeClass == .compact {
            return 50
        } else {
            return 100
        }
    }
    
    init(systemImage: String, informationText: String) {
        self.systemImage = systemImage
        self.informationText = informationText
    }
    
    var body: some View {
        GroupBox {
            VStack(spacing: 0) {
                Image(systemName: systemImage)
                    .resizable()
                    .frame(width: imageSize, height: imageSize)
                    .padding(25)
                    .symbolRenderingMode(.multicolor)
                    .symbolEffect(.pulse, isActive: !isReduceMotionEnabled)
                    .accessibilityHidden(true)
                
                if sizeCategory > .accessibilityMedium {
                    ScrollView {
                        Text(informationText)
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .minimumScaleFactor(0.75)
                    }
                } else {
                    Text(informationText)
                        .font(.title3.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .minimumScaleFactor(0.75)
                }
            }
            .padding()
        }
        .padding()
        .frame(maxWidth: sizeCategory > .accessibilityMedium ? .infinity : 600)
    }
}

#Preview {
    PermissionInfoView(systemImage: "xmark", informationText: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries.")
}
