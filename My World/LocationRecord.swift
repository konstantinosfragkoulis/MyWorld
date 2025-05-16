//
//  LocationRecord.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 16/5/25.
//

import Foundation
import SwiftData

@Model
final class LocationRecord {
    @Attribute(.unique) var id: UUID
    var latitude: Double
    var longitude: Double
    var timestamp: Date

    init(
        id: UUID = UUID(),
         latitude: Double,
         longitude: Double,
         timestamp: Date = Date()
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
    }
}
