//
//  MapView.swift
//  Znajdz Termin
//
//  Created by Maksymilian Stan on 22/07/2024.
//

import SwiftUI
import MapKit

struct MapView: View {
    @ObservedObject var viewModel: FetchedItemsView.ViewModel
    @Binding var selectedItemID: String?
    @State private var cameraPosition: MapCameraPosition
    @Binding var isSheetShowing: Bool
    @State private var mapStyle: MapStyle = .standard
    @State private var shouldShowMapStyleAlert = false
    
    init(viewModel: FetchedItemsView.ViewModel, selectedItemID: Binding<String?>, isSheetShowing: Binding<Bool>) {
        self.viewModel = viewModel
        _selectedItemID = selectedItemID
        _isSheetShowing = isSheetShowing
        
        if let selected = selectedItemID.wrappedValue, let itemFromID = viewModel.findItemByID(itemID: selected), let lat = itemFromID.latitude, let long = itemFromID.longitude {
            self.cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), latitudinalMeters: 500, longitudinalMeters: 500))
        } else {
            self.cameraPosition = .automatic
        }
    }
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Map(position: $cameraPosition) {
                ForEach(viewModel.queueItems, id: \.uniqueID) { item in
                    if let lat = item.latitude, let long = item.longitude {
                        Annotation(item.queueResult.attributes.provider ?? "", coordinate: CLLocationCoordinate2DMake(lat, long)) {
                            Image(systemName: "stethoscope.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .onTapGesture {
                                    withAnimation {
                                        selectedItemID = nil
                                        selectedItemID = item.id
                                    }
                                }
                        }
                    }
                }
            }
            .mapStyle(mapStyle)
            
            VStack {
                Button {
                    isSheetShowing = false
                } label: {
                    ZStack {
                        Image(systemName: "x.circle.fill")
                            .resizable()
                            .foregroundStyle(.primary)
                    }
                }
                .frame(width: 20, height: 20)
                .padding()
             
                Button {
                    withAnimation {
                        self.cameraPosition = .userLocation(fallback: self.cameraPosition)
                    }
                } label: {
                    Image(systemName: "location.fill")
                        .resizable()
                        .foregroundStyle(.primary)
                }
                .frame(width: 20, height: 20)
                .padding()
                
                Button {
                    shouldShowMapStyleAlert = true
                } label: {
                    Image(systemName: "map.fill")
                        .resizable()
                        .foregroundStyle(.primary)
                }
                .frame(width: 20, height: 20)
                .padding()
            }
            .background(.ultraThickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(2)
        }
        .onChange(of: selectedItemID) { oldValue, newValue in
            withAnimation {
                if let selected = newValue, let itemFromID = viewModel.findItemByID(itemID: selected), let lat = itemFromID.latitude, let long = itemFromID.longitude {
                    self.cameraPosition = .region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: lat, longitude: long), latitudinalMeters: 500, longitudinalMeters: 500))
                } else {
                    self.cameraPosition = .automatic
                }
            }
        }
        .confirmationDialog("Wybierz styl mapy", isPresented: $shouldShowMapStyleAlert) {
            Button("Standardowa") {
                mapStyle = .standard
            }
            
            Button("Satelitarna") {
                mapStyle = .hybrid
            }
        }
    }
}

#Preview {
    MapView(viewModel: FetchedItemsView.ViewModel(networkManager: NetworkManager(), locationManager: AppLocationManager()), selectedItemID: .constant("1"), isSheetShowing: .constant(true))
}
