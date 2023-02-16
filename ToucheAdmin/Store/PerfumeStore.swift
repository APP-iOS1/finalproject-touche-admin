//
//  PerfumeStore.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/10.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

/// Perfume Data를 처리하는 Store
/// 1. Firestore에서 모든 Perfume 데이터를 한 번에 불러온다.
/// 2. 선택된 향수만을 처리해서 Magazine의 CRUD작업에 사용한다.
final class PerfumeStore: ObservableObject {
    /// Firestore 향수 데이터 경로
    private let database = Firestore.firestore().collection("Perfume")
    /// Firestore에 저장된 향수 데이터
    @Published var perfumes: [Perfume] = []
    /// 작성자가 선택한 향수 배열 데이터
    @Published var selectedPerfumes: [Perfume] = []
    /// 다음버튼 활성화 여부
    @Published var isNextButtonDisabled: Bool = false
    /// hover 된 향수 데이터
    @Published var hoverCheckPerfume: Perfume?
    
    init() {
        readPerfumesFromFirestore()
        
        $selectedPerfumes
            .map { $0.isEmpty }
            .assign(to: &$isNextButtonDisabled)
    }
    
    /// Firestore에서 Perfume데이터를 불러오는 함수: 관리자가 향수를 추가하면, 자동으로 데이터 갱신함.
    private func readPerfumesFromFirestore() {
        database
            .addSnapshotListener { [weak self] snapshot, _ in
                if let snapshot = snapshot {
                    self?.perfumes = snapshot.documents.compactMap {
                        try? $0.data(as: Perfume.self)
                    }
                }
            }
    }
    
    /// 선택한 향수들의 Id를 이용해 Firestore에서 데이터 불러오기
    func fetchPerfumes(_ ids: [String]) {
        return database
            .whereField("perfumeId", in: ids)
            .getDocuments { [weak self] snapshot, _ in
                if let snapshot = snapshot {
                    self?.selectedPerfumes = snapshot.documents.compactMap {
                        try? $0.data(as: Perfume.self)
                    }
                }
            }
    }
    
    
    /// 향수 배열(SelectedPerfumes)에 선택한 향수가 존재하는지 여부값 반환
    /// - Parameter perfume: 선택한 향수
    /// - Returns: 존재여부 값
    func checkPerfume(_ perfume: Perfume) -> Bool {
        selectedPerfumes.contains(perfume)
    }
    
    /// 향수 선택하기 모드에서 향수를 hover할때, 체크하는 함수
    /// - Parameters:
    ///   - perfume: 선택된 향수
    ///   - hovering: hover 되었는지 여부 값
    func hasHoverPerfume(_ perfume: Perfume, hovering: Bool) {
        if hovering {
            hoverCheckPerfume = perfume
        } else {
            hoverCheckPerfume = nil
        }
    }
    
    /// 모든 선택된 향수 데이터 삭제
    func clearPerfume() {
        selectedPerfumes.removeAll(keepingCapacity: true)
    }
    
    /// 선택한 향수 추가하기 단, 선택된 향수가 10가 넘으면 안됌.
    /// - Parameter perfume: 선택한 향수
    func selectPerfume(_ perfume: Perfume) {
        // firestore whereField(_:in) method requires less and equal to 10 query counts
        if selectedPerfumes.count < 10 {
            selectedPerfumes.append(perfume)
        }
    }
    
    /// 선택한 향수 없애기
    /// - Parameter perfume: 선택한 향수
    func popPerfume(_ perfume: Perfume) {
        if let index = selectedPerfumes.firstIndex(of: perfume) {
            selectedPerfumes.remove(at: index)
        }
    }
}
