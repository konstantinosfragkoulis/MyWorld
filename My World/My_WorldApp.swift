//
//  My_WorldApp.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 16/5/25.
//

import SwiftUI
import SwiftData

@main
struct My_WorldApp: App {
    @StateObject private var locationManager: LocationManager
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LocationRecord.self,
        ])
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    init() {
        let container = sharedModelContainer
        _locationManager = StateObject(wrappedValue:
            LocationManager(context: container.mainContext)
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(locationManager)
                .onAppear { locationManager.startUpdatingLocation() }
        }
        .modelContainer(sharedModelContainer)
    }
}
