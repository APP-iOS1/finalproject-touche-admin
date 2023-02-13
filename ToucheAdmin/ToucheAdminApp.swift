//
//  ToucheAdminApp.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        FirebaseApp.configure()
    }
}

@main
struct ToucheAdminApp: App {
//    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var accountStore = AccountStore()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
//            MagazineEditView(flow: .constant(.edit))
            ContentView()
                .environmentObject(accountStore)
        }
        .windowToolbarStyle(.unified(showsTitle: false))
    }
}
