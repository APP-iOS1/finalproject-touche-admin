//
//  ToucheAdminApp.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import SwiftUI
import FirebaseCore

@main
struct ToucheAdminApp: App {
    @StateObject var accountStore = AccountStore()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(accountStore)
        }
        .windowToolbarStyle(.unified(showsTitle: false))
    }
}
