//
//  SettingsView.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 1/6/25.
//

import SwiftUI
import SwiftData

func formattedTimestamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH-mm-ss"
    return formatter.string(from: Date())
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var hexagons: [HexRecord]
    
    @EnvironmentObject var settings: AppSettings
    
    @State private var exportDoc: HexDocument = HexDocument(text: "")
    @State private var isExporting: Bool = false
    
    @State private var isImporting: Bool = false
    
    @State private var isShowingResetDialog: Bool = false
    @State private var isShowingDeleteDialog: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("Map")) {
                ColorPicker("Polygon Color", selection: Binding(
                    get: { settings.polygonColor },
                    set: { color in
                        settings.setPolygonColor(color)
                    }
                ))
                
                Slider(value: $settings.opacity,
                       in: 0...1,
                       step: 0.01
                ) {
                    
                } minimumValueLabel: {
                    Image(systemName: "hexagon")
                } maximumValueLabel: {
                    Image(systemName: "hexagon.fill")
                }
                
                Slider(value: $settings.lineWidth, in: 1...5, step: 1)
                
                Picker("Map Style", selection: $settings.mapStyle) {
                    Text("Standard").tag("Standard")
                    Text("Satellite").tag("Satellite")
                    Text("Hybrid").tag("Hybrid")
                }

            }
            
            Section(header: Text("Data")) {
                Button("Export Hexagons") {
                    let allHexagons = hexagons
                        .map { String($0.name) }
                        .joined(separator: "\n")
                    
                    exportDoc = HexDocument(text: allHexagons)
                    isExporting = true
                    
                }
                
                Button("Import Hexagons") {
                    isImporting = true
                }
            }
            .fileExporter(
                isPresented: $isExporting,
                document: exportDoc,
                contentType: .mywrld,
                defaultFilename: "Export - \(formattedTimestamp())"
            ) { result in
                switch result {
                case .success:
                    print("Export succeeded")
                case .failure(let error):
                    print("Export failed: \(error)")
                }
            }
            .fileImporter(
                isPresented: $isImporting,
                allowedContentTypes: [.mywrld],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    guard let url = urls.first else { return }
                    do {
                        let data = try Data(contentsOf: url)
                        guard let str = String(data: data, encoding: .utf8) else { return }
                        
                        let lines = str
                            .split(separator: "\n")
                            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                        
                        for line in lines {
                            if let val = UInt64(line) {
                                if !hexagons.contains(where: { $0.name == val }) {
                                    let record = HexRecord(name: val)
                                    modelContext.insert(record)
                                } else {
                                    print("Record \(line) already exists, skipping.")
                                }
                            } else {
                                print("Could not parse line: \(line) as a UInt64, skipping.")
                            }
                        }
                        try modelContext.save()
                        print("Import succeeded, inserted \(lines.count) records")
                            
                    } catch {
                        print("Import failed: \(error.localizedDescription)")
                    }
                case .failure(let error):
                    print("File selection failed: \(error.localizedDescription)")
                }
            }
            
            Section {
                Button("Reset Settings", role: .destructive) {
                    isShowingResetDialog = true
                }
                .confirmationDialog("Are you sure you want to reset all settings?", isPresented: $isShowingResetDialog, titleVisibility: .visible) {
                    Button("Reset Settings", role: .destructive) {
                        settings.setPolygonColor(.blue)
                        settings.opacity = 0.2
                        settings.lineWidth = 2
                        settings.mapStyle = "Standard"
                    }
                    Button("Cancel", role: .cancel) {
                        isShowingResetDialog = false
                    }
                }
                Button("Delete All Data", role: .destructive) {
                    isShowingDeleteDialog = true
                }
                .confirmationDialog("Are you sure you want to delete all location data?", isPresented: $isShowingDeleteDialog, titleVisibility: .visible) {
                    Button("Delete Data", role: .destructive) {
                        for hexagon in hexagons {
                            modelContext.delete(hexagon)
                        }
                    }
                    Button("Cancel", role: .cancel) {
                        isShowingDeleteDialog = false
                    }
                }
            }
        }
    }
}
