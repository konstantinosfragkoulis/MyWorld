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
    @State private var cachedHexagons: [HexRecord] = []
    @State private var cachedPolygons: [HexPolygon] = []
    
    func updatePolygons(newHexagons: [HexRecord]) {
        guard newHexagons.count != cachedHexagons.count else { return }
        cachedHexagons = newHexagons
        cachedPolygons = polygons(hexagons: newHexagons)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Map(position: $position) {
                UserAnnotation()
                
                ForEach(cachedPolygons) { polygon in
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
            .onChange(of: hexagons) {
                updatePolygons(newHexagons: hexagons)
            }
            .onAppear {
                locationManager.startUpdatingLocation()
                updatePolygons(newHexagons: hexagons)
            }
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
