//
//  MapView.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 1/6/25.
//

import SwiftUI
import MapKit
import SwiftH3
import SwiftData

struct MapView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var locationManager: LocationManager
    @EnvironmentObject private var settings: AppSettings
    @Query private var hexagons: [HexRecord]
    @State private var cachedHexagons: [HexRecord] = []
    @State private var cachedPolygons: [HexPolygon] = []
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    func updatePolygons(newHexagons: [HexRecord]) {
        guard newHexagons.count != cachedHexagons.count else { return }
        cachedHexagons = newHexagons
        cachedPolygons = polygons(hexagons: newHexagons)
    }
    
    var selectedMapStyle: MapStyle {
        switch settings.mapStyle {
        case "Satellite":
            return .imagery
        case "Hybrid":
            return .hybrid
        default:
            return .standard
        }
    }
    
    var body: some View {
        Map(position: $position) {
            UserAnnotation()
            
            ForEach(cachedPolygons) { polygon in
                MapPolygon(coordinates: polygon.coordinates)
                    .stroke(settings.polygonColor, lineWidth: settings.lineWidth)
                    .foregroundStyle(settings.polygonColor.opacity(settings.opacity))
            }
        }
        .mapStyle(selectedMapStyle)
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
