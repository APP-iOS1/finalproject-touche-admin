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
    
    var body: some View {
        List(magazineStore.magazines, selection: $magazineStore.magazine) { magazine in
            NavigationLink(value: magazine) {
                HStack(alignment: .top, spacing: 8.0) {
                    // Content Image...
                    // ===================== FireStorage Issue ===================
//                    AsyncImage(
//                        url: URL(string: magazine.contentImage)) { image in
//                            image
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: 50, height: 50)
//                                .cornerRadius(6)
//
//                        } placeholder: {
//                            ProgressView()
//                        }
//                    DownloadingImageView(
//                        urlString: magazine.contentImage,
//                        key: (magazine.id + "_content"))
//                    .frame(width: 50, height: 50)
//                    .cornerRadius(6)
                    // ========================== comment below ===================
                    Rectangle()
                        .frame(width: 50, height: 50)
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
                    flow = .create
                    magazineStore.magazine = nil
                } label: {
                    Image(systemName: "plus")
                }
                Button {
                    if let magazine = magazineStore.magazine {
                        magazineStore.deleteMagazine(magazine)
                    }
                } label: {
                    Image(systemName: "trash")
                }
            }
        }
    }
}

struct MagazineContentView_Previews: PreviewProvider {
    static var previews: some View {
        MagazineContentView(flow: .constant(.read))
            .environmentObject(MagazineStore())
    }
}
