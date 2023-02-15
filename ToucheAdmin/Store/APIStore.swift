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

enum APIError: Error {
    case badDataFromSephora
    case failDecodingData
    case failUploadingToFirestore
}

class APIStore: ObservableObject {
    @Published var notice: String = ""
    @Published var products: [Product] = []
    @Published var perfumes: [Perfume] = []
    @Published var logs: [Log] = []
    @Published var isLoading: Bool = false
    
    // ==========================================
    private var cursor: QueryDocumentSnapshot?
    let pageSize = 60
    // ==========================================
    
    var cancellables = Set<AnyCancellable>()
    let path = Firestore.firestore()
    private let headers = [
        "X-RapidAPI-Key": "bd60134ebbmsh47ad7cc85cd24d7p1cbc4ejsn3ed23622063e",
        "X-RapidAPI-Host": "sephora.p.rapidapi.com"
    ]
    
    func reset() {
        notice = ""
    }
    
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
                        print("response error: ", response.description)
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
                    self?.logs.insert(log, at: 0)
                case .failure(let error):
                    self?.notice =  "fail: \(error)"
                    self?.isLoading = false
                    let log = Log(content: "FAIL - \(page) Page Products Fectch | REASON - \(error)", date: Date.now.timeIntervalSince1970)
                    self?.logs.insert(log, at: 0)
                }
            } receiveValue: { [weak self] (products: [Product]) in
                self?.products = products
            }
            .store(in: &cancellables)
        isLoading = false
    }
    
    /// taskGroup : [https://dev.to/gualtierofr/create-your-own-asyncsequence-1dkl](https://dev.to/gualtierofr/create-your-own-asyncsequence-1dkl)
    func fetchAllDetailData() async {
        await withThrowingTaskGroup(of: Product.self, body: { group in
            for product in products {
                group.addTask {
                    product
                }
            }

            var iterator = group.makeAsyncIterator()
            do {
                while let nextProduct = try await iterator.next() {
                    try await fetchDetailData(product: nextProduct)
                }
            } catch {
                print(error)
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
                        self.logs.insert(log, at: 0)
                    } catch let error {
                        self.notice = "Uploading Error: \(error.localizedDescription)"
                        let log = Log(content: "FAIL - \(product.brandName) / \(product.displayName) Uploading | REASON - \(error)", date: Date.now.timeIntervalSince1970)
                        self.logs.insert(log, at: 0)
                        throw APIError.failUploadingToFirestore
                    }
                }
                
            } catch let error {
                self.notice = "Decoding Error: \(error.localizedDescription)"
                let log = Log(content: "FAIL - \(product.brandName) / \(product.displayName) Decoding | REASON - \(error)", date: Date.now.timeIntervalSince1970)
                self.logs.insert(log, at: 0)
                throw APIError.failDecodingData
            }
        } catch let error {
            self.notice = "Fetching Error: \(error.localizedDescription)"
            let log = Log(content: "FAIL - \(product.brandName) / \(product.displayName) Fetching | REASON - \(error)", date: Date.now.timeIntervalSince1970)
            self.logs.insert(log, at: 0)
            throw APIError.badDataFromSephora
        }
    }
}
