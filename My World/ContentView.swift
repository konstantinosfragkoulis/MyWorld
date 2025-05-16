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
    @Query private var items: [LocationRecord]
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    
    var body: some View {
        VStack(spacing: 16) {
            Map(position: $position) {
                UserAnnotation()
                
                ForEach(polygons(records: items)) { polygon in
                    MapPolygon(coordinates: polygon.coordinates)
                        .stroke(Color.blue, lineWidth: 2)
                        .foregroundStyle(Color.blue.opacity(0.2))
                        //.fill(Color.blue.opacity(0.2))
                }
            }
            .frame(height: 400)
            .mapControls {
                MapUserLocationButton()
                MapPitchToggle()
            }
            
            Text("Stored Locations:")
                .font(.headline)
            
            List(items) { record in
                VStack(alignment: .leading) {
                    Text(String(format: "Lat: %.5f, Lon: %.5f", record.latitude, record.longitude))
                    Text(record.timestamp, style: .date)
                    Text(record.timestamp, style: .time)
                }
            }
        }
        .padding()
        .onAppear {
            locationManager.startUpdatingLocation()
        }
    }
}

#Preview {
    let schema = Schema([LocationRecord.self])
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
