//
//  Due.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/10.
//

import Foundation
/// 관리자의 할 일 목록
///
/// - Magazine 데이터 처리
/// - Server 작업 처리
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
