//
//  TestView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/10.
//

import SwiftUI

struct TestView: View {
    @State private var selection: Case = .one
    @State private var text: String = ""
    enum Case: String, Identifiable, CaseIterable {
        case one, two, three
        var id: String { self.rawValue }
    }
    var body: some View {
        NavigationStack {
            VStack {
                Picker("Picker", selection: $selection) {
                    ForEach(Case.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
                
                Menu("Menu") {
                    ForEach(Case.allCases) {
                        Button($0.rawValue) {
                            //
                        }.tag($0)
                    }
                }
                
                Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            }
        }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .searchable(text: $text)
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}
