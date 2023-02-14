//
//  MagazineReadView.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import SwiftUI
import FirebaseFirestoreSwift

struct MagazineReadView: View {
    @Binding var flow: Flow
    @EnvironmentObject var magazineStore: MagazineStore
    @EnvironmentObject var perfumeStore: PerfumeStore
    
    var perfumes: [Perfume] {
        if let magazine = magazineStore.magazine {
            perfumeStore.fetchPerfumes(magazine.perfumeIds)
            return perfumeStore.selectedPerfumes
        } else {
            return perfumeStore.selectedPerfumes
        }
    }
    
    var body: some View {
        ZStack {
            if let magazine = magazineStore.magazine {
                ScrollView {
                    VStack(alignment: .center, spacing: 20.0) {
                        Text(magazine.createdDate.toDateFormat().formatted())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        VStack(alignment: .leading, spacing: 6.0) {
                            Text("**Title** : \(magazine.title)")
                            Text("**Sub Title** : \(magazine.subTitle)")
                        } // FORM(TEXT)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title3)
                        
                        VStack(alignment: .leading) {
                            Text("Perfumes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(perfumes, id: \.self) { (perfume: Perfume) in
                                        DownloadingImageView(urlString: perfume.image450, key: perfume.perfumeId)
                                            .frame(width: 100, height: 100)
                                            .cornerRadius(8.0)
                                            .overlay(content: {
                                                if perfumeStore.hoverCheckPerfume != nil  && perfumeStore.hoverCheckPerfume! == perfume {
                                                    ZStack {
                                                        Color.black.opacity(0.5)
                                                            .cornerRadius(8.0)
                                                        
                                                        Text(perfume.displayName)
                                                            .font(.body)
                                                            .fontWeight(.light)
                                                            .foregroundColor(.white)
                                                            .multilineTextAlignment(.center)
                                                    }
                                                }
                                            })
                                            .onHover { hovering in
                                                perfumeStore.hasHoverPerfume(perfume, hovering: hovering)
                                            }
                                    } // LOOP
                                } // LAZYHSTACK
                            } // SCROLL(PERFUMES)
                        } // VSTACK(PERFUMES)
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Content Image")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // ======================== FireStorage Issue ==============
//                                AsyncImage(
//                                    url: URL(string: magazine.contentImage),
//                                    content: { image in
//                                        image
//                                            .resizable()
//                                            .aspectRatio(1.0, contentMode: .fill)
//                                            .frame(width: 250, height: 250)
//                                            .cornerRadius(8.0)
//                                    }) {
//                                        ProgressView()
//                                            .frame(width: 250, height: 250)
//                                    }
                                // ================== Image Cache View ==========================
//                                DownloadingImageView(urlString: magazine.contentImage, key: (magazine.id + "_content"))
//                                    .frame(width: 250, height: 250)
//                                    .cornerRadius(8.0)
                                // ================== comment below =============================
                                Rectangle()
                                    .frame(width: 250, height: 250)
                                // ==============================================================
                            } // VSTACK(CONTENT IMAGE)
                            
                            VStack(alignment: .leading) {
                                Text("Body Image")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                // ======================== FireStorage Issue ==============
//                                AsyncImage(
//                                    url: URL(string: magazine.bodyImage),
//                                    content: { image in
//                                        image
//                                            .resizable()
//                                            .aspectRatio(1.0, contentMode: .fill)
//                                            .frame(width: 250, height: 250)
//                                            .cornerRadius(8.0)
//                                    }) {
//                                        ProgressView()
//                                            .frame(width: 250, height: 250)
//                                    }
                                // ================== comment below =============================
//                                DownloadingImageView(urlString: magazine.bodyImage, key: (magazine.id + "_body"))
//                                    .frame(width: 250, height: 250)
//                                    .cornerRadius(8.0)
                                // ===============================================================
                                Rectangle()
                                    .frame(width: 250, height: 250)
                                // ==============================================================
                            } // VSTACK(BODY IMAGE)
                            
                            Spacer()
                        } // HSTACK(IMAGES)
                        
                        Spacer()
                    } // VSTACK
                }
                .padding()
                .toolbar {
                    ToolbarItem(placement: ToolbarItemPlacement.automatic) {
                        Button("edit") {
                            flow = .edit
                        }
                    }
                }
            } else {
                Image("touche-logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 200, height: 200)
                    .grayscale(1)
                    .clipShape(Circle())
                    .blendMode(BlendMode.luminosity)
            }
        }
        
    }
}

struct MagazineReadView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            MagazineReadView(flow: .constant(.read))
        }
            .environmentObject(PerfumeStore())
            .environmentObject(MagazineStore())
    }
}
