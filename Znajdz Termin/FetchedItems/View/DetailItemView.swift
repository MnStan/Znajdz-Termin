//
//  DetailItemView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 27/06/2024.
//

import SwiftUI

struct DetailItemView: View {
    var itemsNamespace: Namespace.ID
    var dataElement: QueueItem
    @Binding var selectedItemID: String?
    @Environment(\.sizeCategory) var sizeCategory
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    withAnimation(.spring(duration: 0.5, bounce: 0.15)) {
                        selectedItemID = nil
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .foregroundStyle(.primary)
                .accessibilityLabel("Zamknij widok szczegółowy")
            }
            VStack(alignment: .center, spacing: 10) {
                HStack(spacing: 10) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                    
                    VStack {
                        Text(dataElement.queueResult.attributes.provider ?? "Brak informacji")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .drawingGroup()
                            .matchedGeometryEffect(id: "provider\(dataElement.id)", in: itemsNamespace)
                        
                        Text(dataElement.queueResult.attributes.locality ?? "Brak informacji")
                            .font(.subheadline).bold()
                            .padding(2)
                            .matchedGeometryEffect(id: "locality\(dataElement.id)", in: itemsNamespace)
                        
                        Text(dataElement.queueResult.attributes.address ?? "Brak informacji")
                            .font(.subheadline).bold()
                            .padding(2)
                        
                        Text(dataElement.distance)
                            .font(.subheadline.bold())
                            .padding(2)
                            .matchedGeometryEffect(id: "distance\(dataElement.id)", in: itemsNamespace)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            GroupBox(label: Text("Udogodnienia")) {
                VStack(alignment: .leading, spacing: 10) {
                    let benefitsForChildren = dataElement.queueResult.attributes.benefitsForChildren
                    if benefitsForChildren == "Y" {
                        HStack {
                            Image(systemName: "figure.and.child.holdinghands")
                            Text("Świadczenia dla dzieci")
                        }
                    }
                    
                    let toilet = dataElement.queueResult.attributes.toilet
                    if toilet == "Y" {
                        HStack {
                            Image(systemName: "toilet.fill")
                            Text("Toalety")
                        }
                    }
                    
                    let ramp = dataElement.queueResult.attributes.ramp
                    if ramp == "Y" {
                        HStack {
                            Image(systemName: "figure.roll")
                            Text("Rampa dla niepełnosprawnych")
                        }
                    }
                    
                    let carPark = dataElement.queueResult.attributes.carPark
                    if carPark == "Y" {
                        HStack {
                            Image(systemName: "parkingsign.circle.fill")
                            Text("Parking")
                        }
                    }
                    
                    let elevator = dataElement.queueResult.attributes.elevator
                    if elevator == "Y" {
                        HStack {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("Winda")
                        }
                    }
                }
                .padding(.top, 15)
                .frame(maxWidth: .infinity)
            }
            
            GroupBox(label: Text("Informacje o kolejce")) {
                HStack {
                    let statistics = dataElement.queueResult.attributes.statistics
                    let providerData = statistics?.providerData ?? nil
                    
                    GroupBox(label: (providerData != nil && statistics != nil) ? Text("Ostatnia aktualizacja: \(providerData!.update)") : Text("")) {
                        if statistics != nil  {
                            if let providerData {
                                VStack {
                                    Text("Oczekujący")
                                    Text("\(providerData.awaiting)")
                                        .bold()
                                }
                                .padding(.top, 3)
                                
                                VStack {
                                    Text("Średni czas oczekiwania")
                                        .multilineTextAlignment(.center)
                                    Text("\(providerData.averagePeriod ?? 0) dni")
                                        .bold()
                                }
                                .padding(.top, 3)
                                
                            }
                        }
                        
                        if let firstDate = dataElement.queueResult.attributes.dates?.date {
                            VStack {
                                Text("Najbliższy termin")
                                    .multilineTextAlignment(.center)
                                Text(firstDate)
                                    .bold()
                                    .matchedGeometryEffect(id: "date\(dataElement.id)", in: itemsNamespace)
                            }
                            .padding(.top, 3)
                        }
                    }
                    .padding(.top, 10)
                }
            }
            
            GroupBox {
                if let phoneURL = URL(string: "tel:+\(dataElement.queueResult.attributes.phone)") {
                    Link("\(dataElement.queueResult.attributes.phone)", destination: phoneURL)
                        .foregroundColor(.blue)
                        .padding()
                } else {
                    Text("Unable to create phone link.")
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .padding(.top, 3)
            
        }
    }
}

#Preview {
    @Namespace var previewNamespace
    return DetailItemView(itemsNamespace: previewNamespace, dataElement: QueueItem(queueResult: .defaultDataElement, distance: "120 km"), selectedItemID: .constant(""))
}
