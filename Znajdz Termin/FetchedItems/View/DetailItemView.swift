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
    @ObservedObject var viewModel = ViewModel()
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
                        .accessibilityHidden(true)
                    
                    VStack {
                        Text(dataElement.queueResult.attributes.provider ?? "")
                            .font(.headline)
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity)
                            .drawingGroup()
                            .matchedGeometryEffect(id: "provider\(dataElement.id)", in: itemsNamespace)
                        
                        Text(dataElement.queueResult.attributes.locality ?? "")
                            .font(.subheadline).bold()
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(2)
                            .matchedGeometryEffect(id: "locality\(dataElement.id)", in: itemsNamespace)
                        
                        Text(dataElement.queueResult.attributes.address ?? "")
                            .font(.subheadline).bold()
                            .multilineTextAlignment(.center)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(2)
                        
                        Text(dataElement.distance)
                            .font(.subheadline.bold())
                            .padding(2)
                            .matchedGeometryEffect(id: "distance\(dataElement.id)", in: itemsNamespace)
                            .accessibilityLabel("Odległość od Twojej lokalizacji to \(dataElement.distance)")
                    }
                    .accessibilityElement(children: .combine)
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            
            if viewModel.checkIfShouldShowFacilities(attributes: dataElement.queueResult.attributes) {
                GroupBox {
                    VStack(alignment: .leading, spacing: 10) {
                        let benefitsForChildren = dataElement.queueResult.attributes.benefitsForChildren
                        if benefitsForChildren == "Y" {
                            HStack {
                                Image(systemName: "figure.and.child.holdinghands")
                                    .accessibilityHidden(true)
                                Text("Świadczenia dla dzieci")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        let toilet = dataElement.queueResult.attributes.toilet
                        if toilet == "Y" {
                            HStack {
                                Image(systemName: "toilet.fill")
                                    .accessibilityHidden(true)
                                Text("Toalety")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        let ramp = dataElement.queueResult.attributes.ramp
                        if ramp == "Y" {
                            HStack {
                                Image(systemName: "figure.roll")
                                    .accessibilityHidden(true)
                                Text("Rampa dla niepełnosprawnych")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        let carPark = dataElement.queueResult.attributes.carPark
                        if carPark == "Y" {
                            HStack {
                                Image(systemName: "parkingsign.circle.fill")
                                    .accessibilityHidden(true)
                                Text("Parking")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                        
                        let elevator = dataElement.queueResult.attributes.elevator
                        if elevator == "Y" {
                            HStack {
                                Image(systemName: "arrow.up.arrow.down")
                                    .accessibilityHidden(true)
                                Text("Winda")
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .padding(.top, 15)
                    .frame(maxWidth: .infinity)
                } label: {
                    Text("Udogodnienia")
                }
                .accessibilityElement(children: .combine)
                .accessibilityRemoveTraits(.isHeader)
            }
            
            GroupBox {
                HStack {
                    let statistics = dataElement.queueResult.attributes.statistics
                    let providerData = statistics?.providerData ?? nil
                    
                    GroupBox {
                        if statistics != nil  {
                            if let providerData {
                                VStack {
                                    Text("Oczekujący")
                                    Text("\(providerData.awaiting)")
                                        .bold()
                                }
                                .padding(.top, 3)
                                .accessibilityElement(children: .combine)
                                
                                VStack {
                                    Text("Średni czas oczekiwania")
                                        .multilineTextAlignment(.center)
                                    Text("\(providerData.averagePeriod ?? 0) dni")
                                        .bold()
                                }
                                .padding(.top, 3)
                                .accessibilityElement(children: .combine)
                                
                            }
                            
                            
                            if let firstDate = dataElement.queueResult.attributes.dates?.date {
                                VStack {
                                    Text("Najbliższy termin")
                                        .multilineTextAlignment(.center)
                                        .matchedGeometryEffect(id: "firstTermin\(dataElement.id)", in: itemsNamespace)
                                    Text(firstDate)
                                        .bold()
                                        .matchedGeometryEffect(id: "date\(dataElement.id)", in: itemsNamespace)
                                }
                                .padding(.top, 3)
                                .accessibilityElement(children: .combine)
                            }
                        }
                    } label: {
                        if providerData != nil && statistics != nil {
                            Text("Ostatnia aktualizacja: \(providerData!.update)")
                        } else {
                            Text("")
                        }
                    }
                    .padding(.top, 10)
                    .accessibilityElement(children: .combine)
                    .accessibilityRemoveTraits(.isHeader)
                }
            } label: {
                Text("Informacje o kolejce")
            }
            .accessibilityElement(children: .combine)
            
            
            ForEach(viewModel.preparePhoneNumberToDisplay(phoneNumber: dataElement.queueResult.attributes.phone)) { number in
                GroupBox {
                    Link("\(number.phoneNumber)", destination: number.urlPhoneNumber)
                        .foregroundColor(.blue)
                        .padding()
                        .accessibilityLabel("Kliknij aby zadzwonić")
                }
            }
        }
    }
}

#Preview {
    @Namespace var previewNamespace
    return DetailItemView(itemsNamespace: previewNamespace, dataElement: QueueItem(queueResult: .defaultDataElement, distance: "120 km"), selectedItemID: .constant(""))
}
