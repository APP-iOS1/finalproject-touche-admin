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
#if canImport(UIKit)
#endif

class MagazineStore: ObservableObject {
    let storage = Storage.storage()
    let firestore = Firestore.firestore().collection("Magazine")
    @Published var magazines: [Magazine] = []
    @Published var magazine: Magazine?
    
    init() {
        readMagazines()
    }
    
    func readMagazine(_ id: String) {
        firestore.document(id).getDocument { [weak self] snapshot, _ in
            self?.magazine = try? snapshot?.data(as: Magazine?.self)
        }
    }
    
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
    
    //MARK: - Storage에 사진 업로드 후 Firestore에 매거진 문서 생성
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
        }
        
        guard let bodyImage = bodyImage, let contentImage = contentImage else {return}
        await createMagazineAtFirestore(magazine: magazine, bodyImageString: bodyImage, contentImageString: contentImage)
    }
    
    
    
    //MARK: - Firestore에 매거진 문서 생성
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
    
    // MARK: - Delete
    func deleteMagazine(_ magazine: Magazine) {
        firestore.document(magazine.id).delete()
    }

}
