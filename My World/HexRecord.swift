//
//  HexRecord.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 16/5/25.
//

import Foundation
import SwiftData

@Model
final class HexRecord {
    @Attribute(.unique) var id: UUID
    var name: UInt64
    var timestamp: Date

    init(
        id: UUID = UUID(),
         name: UInt64,
         timestamp: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.timestamp = timestamp
    }
}
