//
//  PhotoModelFileManager.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//
//  reference from `Swiftful Thinking` - https://www.youtube.com/watch?v=fmVuOu8XOvQ

import Foundation
import SwiftUI

final class PhotoModelFileManager {
    static let instance = PhotoModelFileManager()
    let folderName = "downloaded_photos"
    
    private init() {
        createFolderIfNeeded()
    }
    
    private func createFolderIfNeeded() {
        guard let url = getFolderPath() else { return }
        
        if !FileManager.default.fileExists(atPath: url.path()) {
            do {
                try FileManager.default.createDirectory(
                    at: url,
                    withIntermediateDirectories: true
                )
            } catch let error {
                print("Error creating folder. \(error)")
            }
        }
    }
    
    private func getFolderPath() -> URL? {
        return FileManager
            .default
            .urls(for: .cachesDirectory, in: .userDomainMask)
            .first?
            .appending(path: folderName, directoryHint: .isDirectory)
    }
    
    // ... / downloaded_photos/image_name.png
    private func getImagePath(key: String) -> URL? {
        guard let folder = getFolderPath() else {
            return nil
        }
        return folder.appending(path: key + ".png")
    }
    
    func add(key: String, value: NSImage) {
        guard
            let data = value.pngDataFrom(),
            let url = getImagePath(key: key) else { return }
        
        do {
            try data.write(to: url)
        } catch let error {
            print(error)
        }
    }
    
    func get(key: String) -> NSImage? {
        guard
            let url = getImagePath(key: key),
            FileManager.default.fileExists(atPath: url.path()) else {
            return nil
        }
        return NSImage(contentsOfFile: url.path())
    }
}
