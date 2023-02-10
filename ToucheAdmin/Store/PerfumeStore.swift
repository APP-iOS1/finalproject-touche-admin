//
//  PerfumeStore.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/10.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class PerfumeStore: ObservableObject {
    @Published var perfumes: [Perfume] = []
    @Published var selectedPerfumes: [Perfume] = []
    @Published var isNextButtonDisabled: Bool = false
    @Published var hoverCheckPerfume: Perfume?
    private let database = Firestore.firestore().collection("Perfume")
    
    init() {
        readPerfumes()
        
        $selectedPerfumes
            .map { $0.isEmpty }
            .assign(to: &$isNextButtonDisabled)
    }
    
    func readPerfumes() {
        database
            .addSnapshotListener { [weak self] snapshot, _ in
                if let snapshot = snapshot {
                    self?.perfumes = snapshot.documents.compactMap {
                        try? $0.data(as: Perfume.self)
                    }
                }
            }
    }
    
    func checkPerfume(_ perfume: Perfume) -> Bool {
        selectedPerfumes.contains(perfume)
    }
    
    func hasHoverPerfume(_ perfume: Perfume, hovering: Bool) {
        if hovering {
            hoverCheckPerfume = perfume
        } else {
            hoverCheckPerfume = nil
        }
    }
    
    func clearPerfume() {
        selectedPerfumes.removeAll(keepingCapacity: true)
    }
    
    func selectPerfume(_ perfume: Perfume) {
        // firestore whereField(_:in) method requires less and equal to 10 query counts
        if selectedPerfumes.count < 10 {
            selectedPerfumes.append(perfume)
        }
    }
    
    func popPerfume(_ perfume: Perfume) {
        if let index = selectedPerfumes.firstIndex(of: perfume) {
            selectedPerfumes.remove(at: index)
        }
    }
    
    func hasHoveringPerfume(_ hovering: Bool) -> Bool {
        hovering
    }
}
