//
//  Magazine.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import Foundation

/// Magazine 데이터 모델
struct Magazine: Identifiable, Codable, Hashable{
    var id: String = UUID().uuidString
    let title: String
    let subTitle: String
    let contentImage: String
    let bodyImage: String
    let createdDate: Double
    let perfumeIds: [String]
}
