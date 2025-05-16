//
//  HexPolygon.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 16/5/25.
//

import CoreLocation

struct HexPolygon: Identifiable {
    let id: UInt64
    let coordinates: [CLLocationCoordinate2D]
}
