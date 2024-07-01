//
//  DetailItemView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import SwiftUI

struct DetailItemView: View {
    var itemsNamespace: Namespace.ID
    @Environment(\.sizeCategory) var sizeCategory
    var dataElement: DataElement
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dataElement.attributes.provider ?? "nic")
                .font(.headline)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .drawingGroup()
                .matchedGeometryEffect(id: "provider\(dataElement.id)", in: itemsNamespace, properties: .size)
            
            Text(dataElement.attributes.address ?? "nic")
            Text(dataElement.attributes.carPark ?? "nic")
            Text(dataElement.attributes.benefitsForChildren ?? "nic")
        }
    }
}

#Preview {
    @Namespace var previewNamespace
    return DetailItemView(itemsNamespace: previewNamespace, dataElement: DataElement.defaultDataElement)
}
