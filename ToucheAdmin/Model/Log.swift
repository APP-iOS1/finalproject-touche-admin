//
//  Log.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//

import Foundation

struct Log: Identifiable {
    var id: String = UUID().uuidString
    let content: String
    let date: Double
}
