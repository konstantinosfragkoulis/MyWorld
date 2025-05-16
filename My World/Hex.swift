//
//  Hex.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 16/5/25.
//

import SwiftUI
import MapKit
import Ch3
import SwiftH3
import CoreLocation

func radToDeg(x: Double) -> Double {
    return x * 180.0 / .pi
}

func convertToCLCoordinates(_ boundary: GeoBoundary) -> [CLLocationCoordinate2D] {
    let tuple = boundary.verts

    let allVerts = [
        tuple.0, tuple.1, tuple.2, tuple.3, tuple.4,
        tuple.5
    ]
    
    return allVerts.prefix(Int(boundary.numVerts)).map { vertex in
        CLLocationCoordinate2D(
            latitude: radToDeg(x: vertex.lat),
            longitude: radToDeg(x: vertex.lon)
        )
    }
}

func polygons(
    records: [LocationRecord],
    resolution: Int32 = 8
) -> [HexPolygon] {
    let cells = records.map {
        H3Index(coordinate: H3Coordinate(lat: $0.latitude, lon: $0.longitude), resolution: resolution)
    }
    for cell in cells {
        print(cell.description)
    }
    let unique = Set(cells)
    
    return unique.compactMap { cell in
        guard let hexNum = UInt64(cell.description, radix: 16) else { fatalError("Invalid H3 Index Hex") }
        var boundary = GeoBoundary()
        h3ToGeoBoundary(hexNum, &boundary)
        print(boundary)
        print(convertToCLCoordinates(boundary))
        return HexPolygon(id: hexNum, coordinates: convertToCLCoordinates(boundary))
    }
    
}
