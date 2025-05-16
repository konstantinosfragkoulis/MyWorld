//
//  LocationManager.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 16/5/25.
//

import Foundation
import CoreLocation
import SwiftData

final class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
    
    private let manager = CLLocationManager()
    private let context: ModelContext
    
    private let distanceFilter: CLLocationDistance = 100       // meters
    private let desiredAccuracy = kCLLocationAccuracyKilometer
    private let coordinateEpsilon = 0.001                       // ~100 m tolerance
    
    init(context: ModelContext) {
        self.context = context
        self.authorizationStatus = manager.authorizationStatus
        super.init()
        
        manager.delegate = self
        
        manager.distanceFilter = distanceFilter
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
        
        let epsilon = coordinateEpsilon
        let targetLat = coord.latitude
        let targetLon = coord.longitude

        let predicate = #Predicate<LocationRecord> {
            // latitude within [targetLat - ε, targetLat + ε]
            $0.latitude >= targetLat - epsilon &&
            $0.latitude <= targetLat + epsilon &&

            // longitude within [targetLon - ε, targetLon + ε]
            $0.longitude >= targetLon - epsilon &&
            $0.longitude <= targetLon + epsilon
        }
        
        // fetch any matching records
        let existing: [LocationRecord]
        do {
            existing = try context.fetch(FetchDescriptor(predicate: predicate))
        }
        catch {
            print("Error fetching existing locations: \(error)")
            existing = []
        }
        
        // only save if there is no duplicate
        if existing.isEmpty {
            let record = LocationRecord(
                latitude: targetLat,
                longitude: targetLon,
                timestamp: loc.timestamp
            )
            context.insert(record)
        }
    }
}
