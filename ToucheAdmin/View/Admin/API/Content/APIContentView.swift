//
//  APIContentView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/15.
//

import SwiftUI

/// API 작업 선택 뷰
struct APIContentView: View {
    @Binding var task: ServerTask
    
    var body: some View {
        List(ServerTask.allCases, selection: $task) { task in
            NavigationLink(value: task) {
                HStack(alignment: .center, spacing: 8.0) {
                    Image(systemName: task.systemName, variableValue: 0.3)
                        .resizable()
                        .aspectRatio(1.0, contentMode: .fit)
                        .frame(width: 20, height: 20)
                    
                    Text(task.title.localized)
                        .font(.headline)
                }
            }
            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
        }
    }
}

