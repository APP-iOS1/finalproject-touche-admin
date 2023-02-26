//
//  MagazineContentView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import SwiftUI

// Magazine 선택, 생성, 삭제 뷰
struct MagazineContentView: View {
    // MARK: - PROPERTIES
    @Binding var flow: Flow
    @State private var hasTrashAlert: Bool = false
    @EnvironmentObject var magazineStore: MagazineStore
    @EnvironmentObject var perfumeStore: PerfumeStore
    
    // MARK: - BODY
    var body: some View {
        List(magazineStore.magazines, selection: $magazineStore.magazine) { magazine in
            NavigationLink(value: magazine) {
                // LIST CELL
                listCell(about: magazine)
            }
            .listRowInsets(.init(top: 10, leading: 0, bottom: 10, trailing: 0))
        }
        .toolbar {
            ToolbarItemGroup(placement: ToolbarItemPlacement.automatic) {
                Button {
                    magazineStore.magazine = nil
                    perfumeStore.clearPerfume()
                    flow = .create
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    hasTrashAlert = true
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .alert("Are you sure deleting this magazine?".localized, isPresented: $hasTrashAlert) {
            Button("Cancel".localized, role: .cancel) {
                //
            }
            Button("Delete".localized, role: .destructive) {
                if let magazine = magazineStore.magazine {
                    magazineStore.deleteMagazine(magazine)
                }
            }
        }
    }
}

private extension MagazineContentView {
    /// 커스텀 리스트 셀
    func listCell(about magazine: Magazine) -> some View {
        HStack(alignment: .top, spacing: 8.0) {
            AsyncImage(
                url: URL(string: magazine.contentImage)) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .cornerRadius(6)

                } placeholder: {
                    ProgressView()
                }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(magazine.title)
                    .font(.headline)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)
                VStack(alignment: .leading, spacing: 0) {
                    Text(magazine.subTitle)
                        .font(.body)
                        .lineLimit(1)
                        .multilineTextAlignment(.leading)
                    Text(magazine.createdDate.toDateFormat().formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        } // HSTACK
    }
}

struct MagazineContentView_Previews: PreviewProvider {
    static var previews: some View {
        MagazineContentView(flow: .constant(.read))
            .environmentObject(MagazineStore())
            .environmentObject(PerfumeStore())
    }
}
