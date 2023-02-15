//
//  APILogView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/15.
//

import SwiftUI

struct APILogView: View {
    @EnvironmentObject var apiStore: APIStore
    @State private var sortOrder = [KeyPathComparator(\Log.date), KeyPathComparator(\Log.content)]
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
            Table(of: Log.self, sortOrder: $sortOrder) {
                TableColumn("Content", sortUsing: KeyPathComparator(\Log.content)) { (log: Log) in
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(log.content)
                            .font(.headline)
                            .fontWeight(.regular)                        
                    }
                }
                TableColumn("Date", sortUsing: KeyPathComparator(\Log.date)) { (log: Log) in
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
            .onChange(of: sortOrder) {
                apiStore.logs.sort(using: $0)
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
