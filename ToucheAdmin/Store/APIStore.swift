//
//  APIStore.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//

import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

class APIStore: ObservableObject {
    // MARK: - PROPERTIES
    @Published var notice: String = ""
    @Published var products: [Product] = []
    @Published var perfumes: [Perfume] = []
    @Published var logs: [Log] = []
    @Published var isLoading: Bool = false
    
    let pageSize = 60
    
    var cancellables = Set<AnyCancellable>()
    let path = Firestore.firestore()
    
    // SEPHORA API HEADER
    private let headers = [
        "X-RapidAPI-Key": "bd60134ebbmsh47ad7cc85cd24d7p1cbc4ejsn3ed23622063e",
        "X-RapidAPI-Host": "sephora.p.rapidapi.com"
    ]
    
    // CUSTOM ERROR
    enum APIError: Error {
        case badDataFromSephora
        case failDecodingData
        case failUploadingToFirestore
    }
    
    
    init() {
        self.fetchLogs()
    }
    
    /// reset function
    func reset() {
        notice = ""
    }
    
    /// Firestore에 저장된 모든 Log 데이터 불러오기, 실시간 반영
    private func fetchLogs() {
        path.collection("Log")
            .addSnapshotListener { [weak self] snapshot, _ in
                if let snapshot = snapshot {
                    self?.logs = snapshot.documents.compactMap {
                        try? $0.data(as: Log.self)
                    }
                }
            }
    }
    
    /// Sephora API/PRODUCT/LIST 항목 데이터 불러오는 함수
    ///
    /// - Perfume데이터가아닌 Product데이터를 불러옴
    /// - `products` 프로퍼티에 저장후, `perfume`데이터를 불러올 예정
    func fetchlistDataFromAPI(page: Int = 1) {
        isLoading = true
        
        notice = "Loading.."
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://sephora.p.rapidapi.com/products/list?categoryId=cat60148&pageSize=\(pageSize)&currentPage=\(page)")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        URLSession.shared.dataTaskPublisher(for: request as URLRequest)
            .receive(on: DispatchQueue.main)
            .tryCompactMap { task -> Data? in
                if let response = task.response as? HTTPURLResponse {
                    switch response.statusCode {
                    case 200..<300:
                        return task.data
                    default:
                        self.notice = "\(response.statusCode) error"
                        let log = Log(content: "FAIL - \(page) Page Products Fectch | REASON - \(response.statusCode) code : \(response.description)", date: Date.now.timeIntervalSince1970)
                        try? self.path.collection("Log").document(log.id).setData(from: log)
                        throw URLError(.badURL)
                    }
                }
                return nil
            }
            .decode(type: Result.self, decoder: JSONDecoder())
            .map { $0.products }
            .retry(3)
            .sink { [weak self] in
                switch $0 {
                case .finished:
                    self?.notice = "success"
                    self?.isLoading = false
                    let log = Log(content: "SUCCESS - \(page) Page Products Fectch", date: Date.now.timeIntervalSince1970)
                    try? self?.path.collection("Log").document(log.id).setData(from: log)
                case .failure(let error):
                    self?.notice =  "fail: \(error)"
                    self?.isLoading = false
                    let log = Log(content: "FAIL - \(page) Page Products Fectch | REASON - \(error)", date: Date.now.timeIntervalSince1970)
                    try? self?.path.collection("Log").document(log.id).setData(from: log)
                }
            } receiveValue: { [weak self] (products: [Product]) in
                self?.products = products
            }
            .store(in: &cancellables)
        
        isLoading = false
    }
    
    /// products 데이터로 모든 perfume 데이터 불러오기
    ///
    /// - thread safe하게 taskGroup사용
    /// - 참고: taskGroup : [https://dev.to/gualtierofr/create-your-own-asyncsequence-1dkl](https://dev.to/gualtierofr/create-your-own-asyncsequence-1dkl)
    func fetchAllDetailData() async {
        await withThrowingTaskGroup(of: Product.self, body: { group in
            /// products 프로퍼티의 데이터를 task group화하기
            for product in products {
                group.addTask {
                    product
                }
            }

            /// task group으로 perfume데이터 가져오기
            var iterator = group.makeAsyncIterator()
            do {
                while let nextProduct = try await iterator.next() {
                    do {
                        try await fetchDetailData(product: nextProduct)
                    } catch {
                        let log = Log(content: "FAIL - \(nextProduct.brandName) / \(nextProduct.displayName) iterator | REASON - \(error)", date: Date.now.timeIntervalSince1970)
                        try? self.path.collection("Log").document(log.id).setData(from: log)
                    }
                }
            } catch {
                let log = Log(content: "FAIL - 'fetchAllDetailData()' iterator | REASON - \(error)", date: Date.now.timeIntervalSince1970)
                try? self.path.collection("Log").document(log.id).setData(from: log)
            }
        })
    }
    
    @MainActor
    func fetchDetailData(product: Product) async throws {
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://sephora.p.rapidapi.com/products/detail?productId=\(product.productId)&preferedSku=2210607")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 60.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        var longDescription: String = ""
        var quickDescription: String = ""
        
        do {
            // ------------------- products/detail fetching ------------------------------
            let (data, response) = try await URLSession.shared.data(for: request as URLRequest)
            guard let response = response as? HTTPURLResponse,
                  (200..<300).contains(response.statusCode) else { return }
            do {
              // ------------------- json decoding ------------------------------
                let detailData = try JSONDecoder().decode(Detail.self, from: data)
                longDescription = detailData.longDescription
                quickDescription = detailData.quickLookDescription
                
                let (family, finalType, finalKeyNotes) = makeDescription(longDesc: longDescription)
                
                if PerfumeColor.types.contains(where: {$0.name == finalType}) {
                    let perfume = Perfume(
                        perfumeId: product.productId,
                        brandName: product.brandName,
                        displayName: product.displayName,
                        heroImage: product.heroImage,
                        image450: product.image450,
                        fragranceFamily: family,
                        scentType: finalType,
                        keyNotes: finalKeyNotes,
                        fragranceDescription: quickDescription,
                        likedPeople: [],
                        commentCount: 0,
                        totalPerfumeScore: 0
                    )
                    
                    do {
                        // ------------------- uploading to firestore ------------------------------
                        try self.path.collection("Perfume").document(perfume.perfumeId).setData(from: perfume)
                        self.perfumes.append(perfume)
                        self.notice = "Success uploading perfume data to firestore(collection name: `Perfume`)"
                        let log = Log(content: "SUCCESS - \(product.brandName) / \(product.displayName) Uploading", date: Date.now.timeIntervalSince1970)
                        try self.path.collection("Log").document(log.id).setData(from: log)
                    } catch let error {
                        self.notice = "Uploading Error: \(error.localizedDescription)"
                        let log = Log(content: "FAIL - \(product.brandName) / \(product.displayName) Uploading | REASON - \(error)", date: Date.now.timeIntervalSince1970)
                        try self.path.collection("Log").document(log.id).setData(from: log)
                        throw APIError.failUploadingToFirestore
                    }
                }
                
            } catch let error {
                self.notice = "Decoding Error: \(error.localizedDescription)"
                let log = Log(content: "FAIL - \(product.brandName) / \(product.displayName) Decoding | REASON - \(error)", date: Date.now.timeIntervalSince1970)
                try self.path.collection("Log").document(log.id).setData(from: log)
                throw APIError.failDecodingData
            }
        } catch let error {
            self.notice = "Fetching Error: \(error.localizedDescription)"
            let log = Log(content: "FAIL - \(product.brandName) / \(product.displayName) Fetching | REASON - \(error)", date: Date.now.timeIntervalSince1970)
            try self.path.collection("Log").document(log.id).setData(from: log)
            throw APIError.badDataFromSephora
        }
    }
}
