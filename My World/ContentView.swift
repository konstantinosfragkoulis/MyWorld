//
//  ContentView.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 16/5/25.
//

import SwiftUI
import SwiftData
import MapKit
import SwiftH3

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var locationManager: LocationManager
    @Query private var hexagons: [HexRecord]
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        VStack(spacing: 16) {
            Map(position: $position) {
                UserAnnotation()
                
                ForEach(polygons(hexagons: hexagons)) { polygon in
                    MapPolygon(coordinates: polygon.coordinates)
                        .stroke(Color.blue, lineWidth: 2)
                        .foregroundStyle(Color.blue.opacity(0.2))
                }
            }
            .mapControls {
                MapUserLocationButton()
                MapPitchToggle()
                MapCompass()
            }
        }
        .onAppear {
            locationManager.startUpdatingLocation()
        }
    }
}

#Preview {
    let schema = Schema([HexRecord.self])
    let previewContainer = try! ModelContainer(
        for: schema,
        configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
    )
    
    ContentView()
        .modelContainer(previewContainer)
        .environmentObject(
            LocationManager(context: previewContainer.mainContext)
        )
}
