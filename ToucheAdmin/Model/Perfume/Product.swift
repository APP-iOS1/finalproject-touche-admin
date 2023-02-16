//
//  Product.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//

import Foundation

/// Sephora API에서 './product/list'해당하는 데이터
struct Product: Codable, Identifiable {
    var brandName: String
    var displayName: String
    var heroImage: String
    var productId: String
    var image450: String
    var id: String { self.productId }
}
