//
//  LocationManager.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 16/5/25.
//

import Foundation
import CoreLocation
import SwiftData
import SwiftH3
import Ch3

final class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
    
    private let manager = CLLocationManager()
    private let context: ModelContext
    
    private let desiredAccuracy = kCLLocationAccuracyHundredMeters
    
    init(context: ModelContext) {
        self.context = context
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        
        manager.delegate = self
        
        manager.desiredAccuracy = desiredAccuracy
        
        manager.allowsBackgroundLocationUpdates = true
        manager.pausesLocationUpdatesAutomatically = false
        
        // Ask for When In Use first
        manager.requestWhenInUseAuthorization()
    }
    
    func startUpdatingLocation() {
        switch authorizationStatus {
        case .authorizedAlways:
            // start both services
            manager.startUpdatingLocation()
            manager.startMonitoringSignificantLocationChanges()
            
        case .authorizedWhenInUse:
            // bump up to always
            manager.requestAlwaysAuthorization()
            
        default:
            break
        }
    }
    
    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
        manager.stopMonitoringSignificantLocationChanges()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        
        if authorizationStatus == .authorizedAlways {
            startUpdatingLocation()
        } else if authorizationStatus == .authorizedWhenInUse {
            // ask for Always
            manager.requestAlwaysAuthorization()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        let coord = loc.coordinate
        
        let targetLat = coord.latitude
        let targetLon = coord.longitude
        
        // Get the hexagon that the user is currently in as a UInt64
        guard let curHex = UInt64(H3Index(coordinate: H3Coordinate(lat: targetLat, lon: targetLon), resolution: 8).description, radix: 16) else { return }

        // If the current hexagon is not already stored in SwiftData as a HexRecord, save it
        var descriptor = FetchDescriptor<HexRecord>(
            predicate: #Predicate { $0.name == curHex },
        )
        descriptor.fetchLimit = 1
        var existing: [HexRecord]
        do {
            existing = try context.fetch(descriptor)
        }
        catch {
            print("Error fetching existing hexagons: \(error)")
            existing = []
        }
        
        if existing.isEmpty {
            let record = HexRecord(name: curHex)
            print("New Hex Record: \(curHex)!!!")
            context.insert(record)
        }
    }
}
