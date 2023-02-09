//
//  Double+.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import Foundation

extension Double {
    func toDateFormat() -> Date {
        return Date.init(timeIntervalSince1970: self)
    }
}
