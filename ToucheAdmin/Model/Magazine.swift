//
//  Magazine.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import Foundation

struct Magazine: Identifiable, Codable, Hashable{
    var id: String = UUID().uuidString
    let title: String
    let subTitle: String
    let contentImage: String
    let bodyImage: String
    let createdDate: Double
    let perfumeIds: [String]
    
    static let dummy: [Magazine] =
         (0..<10).map { i in
             Magazine(title: "\(i) title", subTitle: "\(i) sub title", contentImage: "\(i) contentImage", bodyImage: "\(i) bodyImage", createdDate: Date.now.timeIntervalSince1970, perfumeIds: ["\(i)"])
        }
    
}
