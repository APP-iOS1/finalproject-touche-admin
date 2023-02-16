//
//  NSTextField+.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import SwiftUI

/// TextField 링 처리
extension NSTextField {
    open override var focusRingType: NSFocusRingType {
        get {.none}
        set {}
    }
}
