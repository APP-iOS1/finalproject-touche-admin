//
//  MagazineContentView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import SwiftUI


struct MagazineContentView: View {
    @Binding var flow: Flow
    @EnvironmentObject var magazineStore: MagazineStore
    @EnvironmentObject var perfumeStore: PerfumeStore
    @State private var hasTrashAlert: Bool = false
    
    var body: some View {
        List(magazineStore.magazines, selection: $magazineStore.magazine) { magazine in
            NavigationLink(value: magazine) {
                HStack(alignment: .top, spacing: 8.0) {
                    // Content Image...
                    // ===================== FireStorage Issue ===================
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
//                    ForEach([magazine], id: \.id) { magazine in
//                        DownloadingImageView(
//                            urlString: magazine.contentImage,
//                            key: "\(magazine.id)Content")
//                            .frame(width: 50, height: 50)
//                            .cornerRadius(6)
//                    }
                    // ========================== comment below ===================
//                    Rectangle()
//                        .fill(Material.ultraThickMaterial)
//                        .frame(width: 50, height: 50)
//                        .overlay {
//                            Text("Storage 사용량 초과로 인한 임시조치\n(썸네일 사진 영역)")
//                                .font(.title)
//                                .fontWeight(.semibold)
//                                .multilineTextAlignment(.center)
//                        }
                    // ============================================================
                    
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
                }
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
        .alert("Are you sure deleting this magazine?", isPresented: $hasTrashAlert) {
            Button("Cancel", role: .cancel) {
                //
            }
            Button("Delete", role: .destructive) {
                if let magazine = magazineStore.magazine {
                    magazineStore.deleteMagazine(magazine)
                }
            }
        }
    }
}

struct MagazineContentView_Previews: PreviewProvider {
    static var previews: some View {
        MagazineContentView(flow: .constant(.read))
            .environmentObject(MagazineStore())
            .environmentObject(PerfumeStore())
    }
}
