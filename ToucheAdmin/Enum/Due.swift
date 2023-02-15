//
//  Due.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/10.
//

import Foundation
enum Due: String, Identifiable, CaseIterable {
    
    case magazine
    case server
    
    var id: String { self.rawValue }
    var title: String { self.rawValue }
    var systemName: String {
        switch self {
        case .magazine: return "square.and.pencil"
        case .server: return "server.rack"
        }
    }
}
