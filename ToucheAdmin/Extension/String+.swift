//
//  String+.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/26.
//

import Foundation

extension String {
    var localized: String {
        return NSLocalizedString(self, tableName: "Localizable", value: self, comment: "")
    }
}
