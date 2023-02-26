//
//  APINetworkView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/15.
//

import SwiftUI

/// Sephora API에서 데이터를 가져와 Firestore로 옮기는 작업하는 뷰
struct APINetworkView: View {
    // MARK: - PROPERTIES
    @State private var selectedProduct: Product.ID?
    @State private var sortOrder = [KeyPathComparator(\Product.brandName), KeyPathComparator(\Product.displayName), KeyPathComparator(\Product.id)]
    @AppStorage("page") private var page: Int = 1
    
    @EnvironmentObject var apiStore: APIStore
    
    // MARK: - BODY
    var body: some View {
        VStack(alignment: .leading, spacing: 20.0) {
            // title
            Text("network".localized.uppercased())
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.horizontal)
                .padding(.top)
            
            // product fetch button group
            HStack {
                Button {
                    if page > 1 {
                        page -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                }
                
                Text("Page \(page)".localized)
                
                Button {
                    if page < 20 {
                        page += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                }
                
                Button("Fetch Product!".localized) {
                    apiStore.fetchlistDataFromAPI(page: page)
                }
                
                Spacer()
                
                Button("Upload All Product!".localized) {
                    Task {
                        apiStore.isLoading.toggle()
                        await apiStore.fetchAllDetailData()
                        apiStore.isLoading.toggle()
                    }
                }
                .disabled(apiStore.products.isEmpty)
            }
            .padding(.horizontal)
            .padding(.top)
            
            // product Table
            Table(of: Product.self, selection: $selectedProduct) {
                TableColumn("Id".localized, value: \.productId)
                    .width(80.0)
                TableColumn("Brand".localized, value: \.brandName)
                    .width(120.0)
                TableColumn("Product".localized, value: \.displayName)
                TableColumn("Uploded".localized) { (product: Product) in
                    Circle()
                        .fill(apiStore.perfumes.contains(where: {$0.perfumeId == product.productId}) ? .green : .red)
                        .frame(maxWidth: 20.0, alignment: .center)
                }
                .width(80.0)
            } rows: {
                ForEach(apiStore.products) { (product: Product) in
                    TableRow(product)
                }
            }
            .onChange(of: sortOrder, perform: {
                apiStore.products.sort(using: $0)
            })
            .onChange(of: selectedProduct) { productId in
                if let productId = productId,
                   let product = apiStore.products.first(where: {$0.productId == productId}) {
                    Task {
                        apiStore.isLoading.toggle()
                        try await apiStore.fetchDetailData(product: product)
                        apiStore.isLoading.toggle()
                    }
                }
            }
        }
        .overlay {
            if apiStore.isLoading {
                ProgressView()
                    .frame(width: 50, height: 50)
                    .padding()
                    .background(Material.ultraThickMaterial)
                    .clipShape(Circle())
            }
        }
    }
}

struct APINetworkView_Previews: PreviewProvider {
    static var previews: some View {
        APINetworkView()
            .environmentObject(APIStore())
    }
}
