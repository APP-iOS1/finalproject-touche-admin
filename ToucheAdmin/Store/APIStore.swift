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
    
    //    private func fetch() {
    //        switch cursor {
    //        case nil:
    //            path.collection("Perfume")
    //                .limit(to: pageSize)
    //                .getDocuments { [weak self] (snapshot: QuerySnapshot?, _ :Error?) in
    //                    guard let snapshot = snapshot else { return }
    //
    //                    guard let lastSnapshot = snapshot.documents.last else {
    //                        // The collection is empty.
    //                        self?.cursor = nil
    //                        return
    //                    }
    //
    //                    self?.cursor = lastSnapshot
    //
    //                    self?.perfumes = snapshot.documents.compactMap { query -> Perfume? in
    //                        do {
    //                            return try query.data(as: Perfume.self)
    //                        } catch {
    //                            return nil
    //                        }
    //                    }
    //                }
    //        default:
    //            path.collection("Perfume")
    //                .limit(to: pageSize)
    //                .start(afterDocument: cursor!)
    //                .getDocuments { [weak self] (snapshot: QuerySnapshot?, _ :Error?) in
    //                    guard let snapshot = snapshot else { return }
    //
    //                    guard let lastSnapshot = snapshot.documents.last else {
    //                        // The collection is empty.
    //                        self?.cursor = nil
    //                        return
    //                    }
    //
    //                    self?.cursor = lastSnapshot
    //
    //                    self?.perfumes = snapshot.documents.compactMap { query -> Perfume? in
    //                        do {
    //                            return try query.data(as: Perfume.self)
    //                        } catch {
    //                            return nil
    //                        }
    //                    }
    //                }
    //
    //        }
    //    }
    //
    
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
                    let log = Log(content: "FAIL - \(page) Page Products Fectch\nREASON - \(error)", date: Date.now.timeIntervalSince1970)
                    self?.logs.insert(log, at: 0)
                }
            } receiveValue: { [weak self] (products: [Product]) in
                self?.products = products
            }
            .store(in: &cancellables)
    }
    
    //    @Sendable @MainActor
    //    private func refreshProductData() async -> Void {
    //        self.products = await withCheckedContinuation { (continuation: CheckedContinuation<[Product], Never>) in
    //            path.collection("temps")
    ////                .limit(to: pageSize)
    //                .getDocuments { (snapshot: QuerySnapshot?, _ :Error?) in
    //                    guard let snapshot = snapshot else { return }
    //                    let products = snapshot.documents.compactMap { query -> Product? in
    //                        do {
    //                            return try query.data(as: Product.self)
    //                        } catch {
    //                            return nil
    //                        }
    //                    }
    //                    continuation.resume(returning: products)
    //                }
    //        }
    //    }
    
//    func fetchAllDetailData() async {
//        await withThrowingTaskGroup(of: Product.self, body: { group in
//            for product in products {
//                group.addTask {
//                    product
//                }
//            }
//
//            group.
//        })
//    }
    
    func fetchDetailData(product: Product) async throws {
        
        // ------------------- products/detail fetching ------------------------------
        
        isLoading = true
        
        let request = NSMutableURLRequest(url: NSURL(string: "https://sephora.p.rapidapi.com/products/detail?productId=\(product.productId)&preferedSku=2210607")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        
        var longDescription: String = ""
        var quickDescription: String = ""
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                self.notice = "datatask error : " + String(describing: error?.localizedDescription)
                self.isLoading = false
                
            } else {
                if let jsonData = try? JSONDecoder().decode(Detail.self, from: data ?? Data()),
                   let response = response as? HTTPURLResponse {
                    print(response.statusCode)
                    longDescription = jsonData.longDescription
                    quickDescription = jsonData.quickLookDescription
                    
                    // --------------------- (family, finalType, finalKeyNotes) ------------------
                    
                    let (family, finalType, finalKeyNotes) = makeDescription(longDesc: longDescription)
                    
                    // ------------------ firestore ------------------------------
                    
                    if finalType == PerfumeColor.types[0].name || finalType == PerfumeColor.types[1].name || finalType == PerfumeColor.types[2].name || finalType == PerfumeColor.types[3].name || finalType == PerfumeColor.types[4].name || finalType == PerfumeColor.types[5].name || finalType == PerfumeColor.types[6].name || finalType == PerfumeColor.types[7].name || finalType == PerfumeColor.types[8].name || finalType == PerfumeColor.types[9].name || finalType == PerfumeColor.types[10].name || finalType == PerfumeColor.types[11].name || finalType == PerfumeColor.types[12].name || finalType == PerfumeColor.types[13].name || finalType == PerfumeColor.types[14].name || finalType == PerfumeColor.types[15].name {
                        
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
                        
                        
//                        self.path.collection("Perfume").document(product.productId)
//                            .setData(perfume)
                        do {
                            try self.path.collection("Perfume").document(perfume.perfumeId).setData(from: perfume)
                            DispatchQueue.main.async {
                                self.perfumes.append(perfume)
                                self.notice = "Success uploading perfume data to firestore(collection name: `Perfume`)"
                                let log = Log(content: "SUCCESS - \(product.brandName) / \(product.displayName) Uploading", date: Date.now.timeIntervalSince1970)
                                self.logs.insert(log, at: 0)
                                self.isLoading = false
                            }
                        } catch let error {
                            self.notice = "Error: \(error.localizedDescription)"
                            let log = Log(content: "FAIL - \(product.brandName) / \(product.displayName) Uploading\nREASON - \(error)", date: Date.now.timeIntervalSince1970)
                            self.logs.insert(log, at: 0)
                            self.isLoading = false
                        }
                        
                    }
                } else {
                    DispatchQueue.main.async {
                        self.notice = "json decoding fail: " + String(describing: error?.localizedDescription)
                        let log = Log(content: "FAIL - \(product.brandName) / \(product.displayName) Uploading\nREASON - \(self.notice)", date: Date.now.timeIntervalSince1970)
                        self.logs.insert(log, at: 0)
                        self.isLoading = false
                    }
                }
            }
        })
        
        dataTask.resume()
    }
}
