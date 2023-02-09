//
//  NSImage+.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import AppKit

extension NSImage {
    /// linke from [https://gist.github.com/zappycode/3b5e151d4d98407901af5748745f5845](https://gist.github.com/zappycode/3b5e151d4d98407901af5748745f5845)
    func jpegDataFrom(image:NSImage) -> Data {
            let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil)!
            let bitmapRep = NSBitmapImageRep(cgImage: cgImage)
            let jpegData = bitmapRep.representation(using: NSBitmapImageRep.FileType.jpeg, properties: [:])!
            return jpegData
        }
}
