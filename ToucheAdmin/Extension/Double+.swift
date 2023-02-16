//
//  Double+.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import Foundation

/// Double타입에서 Date타입으로 변환
extension Double {
    func toDateFormat() -> Date {
        return Date.init(timeIntervalSince1970: self)
    }
}
