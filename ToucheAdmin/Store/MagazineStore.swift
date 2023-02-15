//
//  TestMagazine.swift
//  ToucheFinal
//
//  Created by TAEHYOUNG KIM on 2023/02/09.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage
import Combine
#if canImport(UIKit)
#endif

/// Magazine데이터를 처리하는 스토어
///
/// - Flow Chart
///     > local(CRUD) - storage(image data) - firestore - 자동으로 local에 반영됨.
class MagazineStore: ObservableObject {
    let storage = Storage.storage()
    let firestore = Firestore.firestore().collection("Magazine")
    @Published var magazines: [Magazine] = []
    @Published var magazine: Magazine?
    @Published var status: Status = .create
    
    enum Status {
        case edit
        case create
    }
    
    init() {
        readMagazines()
        
        $magazines
            .map { $0.first }
            .assign(to: &$magazine)
    }
    
    /// Firestore에서 Magazine 데이터, 최신시간순으로 정렬해서 불러오기
    func readMagazines() {
        firestore
            .order(by: "createdDate", descending: true)
            .addSnapshotListener { [weak self] snapshot, _ in
                if let snapshot = snapshot {
                    self?.magazines = snapshot.documents.compactMap {
                        try? $0.data(as: Magazine.self)
                    }
                }
            }
    }
    
    /// Magazine 데이터를 Firestore, Storage에 저장하기 위한 함수
    /// - Parameters:
    ///   - magazine: magazine 데이터
    ///   - selectedContentUImage: 메인 이미지
    ///   - selectedBodyUImage: 바디 이미지
    func createMagazine(magazine: Magazine, selectedContentUImage: NSImage?, selectedBodyUImage: NSImage?) async {

        var contentImage: String?
        var bodyImage:String?
        
        let contentImageRef = storage.reference(withPath: "magazine/\(magazine.id)/contentImage")
        guard let selectedContentImage = selectedContentUImage else { return }
        var imageData = selectedContentImage.jpegDataFrom(image: selectedContentImage)
        do {
            let _ = try await contentImageRef.putDataAsync(imageData)
            let contentImageString = try await contentImageRef.downloadURL()
            print(contentImageString.absoluteString)
            
            contentImage = contentImageString.absoluteString
        } catch {
            print("contentImage upload error")
            print(error)
        }
        
        
        let bodyImageRef = storage.reference(withPath: "magazine/\(magazine.id)/bodyImage")
        guard let selectedBodyImage = selectedBodyUImage else { return }
        imageData = selectedBodyImage.jpegDataFrom(image: selectedBodyImage)
        do {
            let _ = try await bodyImageRef.putDataAsync(imageData)
            let bodyImageString = try await bodyImageRef.downloadURL()
            print(bodyImageString.absoluteString)
            
            bodyImage = bodyImageString.absoluteString
        } catch {
            print("bodyImage upload error")
            print(error)
        }
        
        guard let bodyImage = bodyImage, let contentImage = contentImage else {return}
        await createMagazineAtFirestore(magazine: magazine, bodyImageString: bodyImage, contentImageString: contentImage)
    }
    
    /// Firestore에 Magazine을 저장하기 위한 헬퍼함수
    /// - Parameters:
    ///   - magazine: magazine 데이터
    ///   - bodyImageString: 메인 이미지 url
    ///   - contentImageString: 바디 이미지 url
    private func createMagazineAtFirestore(magazine: Magazine, bodyImageString: String, contentImageString: String) async {
        do {
            try await firestore.document(magazine.id).setData([
                "id": magazine.id,
                "title": magazine.title,
                "subTitle": magazine.subTitle,
                "contentImage": contentImageString,
                "bodyImage": bodyImageString,
                "createdDate": magazine.createdDate,
                "perfumeIds": magazine.perfumeIds
            ])
            print("매거진 생성")
        } catch {
            print("매거진 생성 실패")
        }
    }
    
    /// Magazine 데이터 Firestore, Storage에서 삭제
    /// - Parameters:
    ///     - magazine: 선택한 magazine 데이터
    func deleteMagazine(_ magazine: Magazine) {
        firestore.document(magazine.id).delete()
        storage.reference(withPath: "magazine/\(magazine.id)/contentImage").delete(completion: nil)
        storage.reference(withPath: "magazine/\(magazine.id)/bodyImage").delete(completion: nil)
    }

}
