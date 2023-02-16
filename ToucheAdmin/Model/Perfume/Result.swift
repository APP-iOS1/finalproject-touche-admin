//
//  Result.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//

import Foundation

/// Sephora API에서 './product/list' 경로의 Product데이터를 얻기위한 중간 데이터모델
struct Result: Codable{
    var products: [Product]
}
