//
//  AppSettings.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 1/6/25.
//

import SwiftUI
import UIKit

extension Color {
    func archivedData() -> Data? {
        let uiColor = UIColor(self)
        return try? NSKeyedArchiver.archivedData(
            withRootObject: uiColor,
            requiringSecureCoding: false
        )
    }
    
    static func fromArchivedData(_ data: Data) -> Color? {
        guard let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) else {
            return nil
        }
        return Color(uiColor)
    }
}

class AppSettings: ObservableObject {
    
    private enum Keys {
        static let polygonColor = "polygonColor"
        static let opacity = "opacity"
        static let lineWidth = "lineWidth"
        static let mapStyle = "mapStyle"
    }
    
    @Published var polygonColor: Color {
        didSet {
            UserDefaults.standard.set(polygonColor.archivedData(), forKey: Keys.polygonColor)
        }
    }
    @Published var opacity: Double {
        didSet {
            UserDefaults.standard.set(opacity, forKey: Keys.opacity)
        }
    }
    @Published var lineWidth: Double {
        didSet {
            UserDefaults.standard.set(lineWidth, forKey: Keys.lineWidth)
        }
    }
    @Published var mapStyle: String {
        didSet {
            UserDefaults.standard.set(mapStyle, forKey: Keys.mapStyle)
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: Keys.polygonColor),
           let c = Color.fromArchivedData(data) {
            self.polygonColor = c
        } else {
            self.polygonColor = .blue
        }
        
        self.opacity = UserDefaults.standard.object(forKey: Keys.opacity) as? Double ?? 0.2
        
        self.lineWidth = UserDefaults.standard.object(forKey: Keys.lineWidth) as? Double ?? 2
        
        self.mapStyle = UserDefaults.standard.object(forKey: Keys.mapStyle) as? String ?? "Standard"
    }
    
    func setPolygonColor(_ color: Color) {
        polygonColor = color
    }
}
