//
//  ServerTask.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//

import Foundation

enum ServerTask: String, Identifiable, CaseIterable {
    
    case log
    case network
    
    var id: String { self.rawValue }
    var title: String { self.rawValue }
    var systemName: String {
        switch self {
        case .log: return "book"
        case .network: return "network"
        }
    }
}
