//
//  HexDocument.swift
//  My World
//
//  Created by Konstantinos Fragkoulis on 1/6/25.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let mywrld = UTType(filenameExtension: "mywrld")!
}

struct HexDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.mywrld] }
    var text: String
    
    init(text: String = "") {
        self.text = text
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let hexRecords = String(data: data, encoding: .utf8)
        else {
            throw CocoaError(.fileReadCorruptFile)
        }
        
        self.text = hexRecords
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = Data(text.utf8)
        return .init(regularFileWithContents: data)
    }
}
