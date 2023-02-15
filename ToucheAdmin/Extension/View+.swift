//
//  View+.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import SwiftUI

extension View {
    func getRect() -> CGRect {
        NSScreen.main!.visibleFrame
    }
}
