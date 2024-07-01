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
    var dataElement: DataElement
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dataElement.attributes.provider ?? "nic")
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity)
                .drawingGroup()
                .matchedGeometryEffect(id: "provider\(dataElement.id)", in: itemsNamespace, properties: .size)
        }
    }
}

#Preview {
    @Namespace var previewNamespace
    return ItemView(itemsNamespace: previewNamespace, dataElement: DataElement.defaultDataElement)
}
