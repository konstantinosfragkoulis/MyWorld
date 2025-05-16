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
import SwiftData

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
    hexagons: [HexRecord],
    resolution: Int32 = 8
) -> [HexPolygon] {
    print("CALLED FUNCTION POLYGONS!!!")
    
    return hexagons.compactMap { hex in
        // guard let hexNum = UInt64(cell.description, radix: 16) else { fatalError("Invalid H3 Index Hex") }
        var boundary = GeoBoundary()
        h3ToGeoBoundary(hex.name, &boundary)
        print("\n")
        print(boundary)
        print(convertToCLCoordinates(boundary))
        print("\n")
        return HexPolygon(id: hex.name, coordinates: convertToCLCoordinates(boundary))
    }
    
}
