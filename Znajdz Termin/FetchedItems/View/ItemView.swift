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
    var dataElement: QueueItem
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dataElement.queueResult.attributes.provider ?? "Nieznane")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .drawingGroup()
                .matchedGeometryEffect(id: "provider\(dataElement.id)", in: itemsNamespace)
                .accessibilityLabel("\(dataElement.queueResult.attributes.provider ?? "Nieznane") dotknij aby rozwinąć szczegóły")
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Najbliższa termin")
                    Text(dataElement.queueResult.attributes.dates?.date ?? "")
                        .matchedGeometryEffect(id: "date\(dataElement.id)", in: itemsNamespace)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(dataElement.queueResult.attributes.locality ?? "Nieznana")
                        .matchedGeometryEffect(id: "locality\(dataElement.id)", in: itemsNamespace)
                    Text(dataElement.distance)
                        .matchedGeometryEffect(id: "distance\(dataElement.id)", in: itemsNamespace)
                }
            }
        }
    }
}

#Preview {
    @Namespace var previewNamespace
    return ItemView(itemsNamespace: previewNamespace, dataElement: QueueItem(queueResult: DataElement.defaultDataElement, distance: "120 km"))
}
