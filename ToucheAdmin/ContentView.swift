//
//  ContentView.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("isSignIn") var isSignIn: Bool = false
    var body: some View {
        switch isSignIn {
        case true:
            VStack {
                Image(systemName: "globe")
                    .imageScale(.large)
                    .foregroundColor(.accentColor)
                Text("Hello, world!")
            }
            .padding()
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
