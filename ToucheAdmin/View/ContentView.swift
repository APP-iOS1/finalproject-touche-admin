//
//  ContentView.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import SwiftUI

/// 메인 컨텐츠 뷰
///
/// - 관리자 뷰
/// - 로그인(계정) 뷰
struct ContentView: View {
    /// 로그인 여부 판단 변수
    @AppStorage("isSignIn") var isSignIn: Bool = false
    
    var body: some View {
        switch isSignIn {
        case true:
            AdminView(isSignIn: $isSignIn)
        case false:
            AccountView(isSignIn: $isSignIn)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
