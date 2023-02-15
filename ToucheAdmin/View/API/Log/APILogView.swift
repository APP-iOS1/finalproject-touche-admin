//
//  APILogView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/15.
//

import SwiftUI

struct APILogView: View {
    @EnvironmentObject var apiStore: APIStore
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            // title
            Text("log".uppercased())
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
            
            // chart
            
            // log table
            Table(of: Log.self) {
                TableColumn("Content") { (log: Log) in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(log.content)
                            .font(.headline)
                            .fontWeight(.regular)                        
                    }
                }
                TableColumn("Date") { (log: Log) in
                    Text(log.date.toDateFormat().formatted())
                        .font(.body)
                        .fontWeight(.regular)
                }
                .width(150.0)
            } rows: {
                ForEach(apiStore.logs) { (log: Log) in
                    TableRow(log)
                }
            }
        }
    }
}

struct APILogView_Previews: PreviewProvider {
    static var previews: some View {
        APILogView()
            .environmentObject(APIStore())
    }
}
