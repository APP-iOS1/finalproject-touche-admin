//
//  Log.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//

import Foundation

/// 로그데이터를 얻기위한 Log 모델
struct Log: Identifiable, Codable {
    var id: String = UUID().uuidString
    let content: String
    let date: Double
}
