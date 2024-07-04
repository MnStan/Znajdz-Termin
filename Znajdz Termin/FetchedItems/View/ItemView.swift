//
//  ItemView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import SwiftUI

struct ItemView: View {
    var itemsNamespace: Namespace.ID
    @Environment(\.sizeCategory) var sizeCategory
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    var dataElement: QueueItem
    @State private var isHStackLayout = false
    
    var body: some View {
        let shouldShowVStack = (sizeCategory >= .accessibilityMedium) && (horizontalSizeClass == .compact)
        let layout = shouldShowVStack == false ? AnyLayout(HStackLayout()) : AnyLayout(VStackLayout(spacing: 10))

        VStack(alignment: shouldShowVStack ? .center :.leading, spacing: 10) {
            Text(dataElement.queueResult.attributes.provider ?? "Nieznane")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .drawingGroup()
                .matchedGeometryEffect(id: "provider\(dataElement.id)", in: itemsNamespace)
                .accessibilityLabel("\(dataElement.queueResult.attributes.provider ?? "Nieznane") dotknij aby rozwinąć szczegóły")
            
            layout {
                VStack(alignment: shouldShowVStack ? .center :.leading) {
                    Text("Najbliższy termin")
                        .matchedGeometryEffect(id: "firstTermin\(dataElement.id)", in: itemsNamespace)
                        .multilineTextAlignment(shouldShowVStack ? .center :.leading)
                    Text(dataElement.queueResult.attributes.dates?.date ?? "")
                        .matchedGeometryEffect(id: "date\(dataElement.id)", in: itemsNamespace)
                        .multilineTextAlignment(shouldShowVStack ? .center :.leading)
                }
                
                if !shouldShowVStack {
                    Spacer()
                }
                
                VStack(alignment: shouldShowVStack ? .center :.leading) {
                    Text(dataElement.queueResult.attributes.locality ?? "Nieznana")
                        .matchedGeometryEffect(id: "locality\(dataElement.id)", in: itemsNamespace)
                        .multilineTextAlignment(shouldShowVStack ? .center :.trailing)
                    Text(dataElement.distance)
                        .matchedGeometryEffect(id: "distance\(dataElement.id)", in: itemsNamespace)
                        .accessibilityLabel("Odległość od Twojej lokalizacji to \(dataElement.distance)")
                        .multilineTextAlignment(shouldShowVStack ? .center :.trailing)
                }
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview {
    @Namespace var previewNamespace
    return ItemView(itemsNamespace: previewNamespace, dataElement: QueueItem(queueResult: DataElement.defaultDataElement, distance: "120 km"))
}
