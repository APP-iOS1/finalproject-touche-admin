//
//  MagazineDetailView.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import SwiftUI
import FirebaseFirestoreSwift

struct MagazineDetailView: View {
//    let selectedMagazine: Magazine
    @State private var title: String = ""
    @State private var subTitle: String = ""
//    @FirestoreQuery private var perfumes: [Perfume]
    var perfumes: [Perfume] = []
    @EnvironmentObject var magazineStore: MagazineStore
    
//    init(selectedMagazine: Magazine) {
//        self.selectedMagazine = selectedMagazine
//        _title = State<String>(wrappedValue: selectedMagazine.title)
//        _subTitle = State<String>(wrappedValue: selectedMagazine.subTitle)
//        _perfumes = FirestoreQuery<[Perfume]>(collectionPath: "Perfume", predicates: [.whereField("perfumeId", isIn: selectedMagazine.perfumeIds)])
//    }
    
    var body: some View {
        ZStack {
            if let magazine = magazineStore.magazine {
                ScrollView {
                    VStack(alignment: .center, spacing: 20.0) {
                        Text(magazine.createdDate.toDateFormat().formatted())
                            .font(.footnote)
                            .foregroundColor(.secondary)
                        
                        Form {
                            TextField(text: $title, prompt: Text("Required.."), axis: .vertical) {
                                Text("Title")
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            TextField(text: $subTitle, prompt: Text("Required.."), axis: .vertical) {
                                Text("Sub Title")
                            }
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        
                        VStack(alignment: .leading) {
                            Text("Perfumes")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack {
                                    ForEach(perfumes, id: \.self) { (perfume: Perfume) in
                                        AsyncImage(
                                            url: URL(string: perfume.image450),
                                            content: { image in
                                                image
                                                    .resizable()
                                                    .aspectRatio(1.0, contentMode: .fill)
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(8.0)
                                            }) {
                                                ProgressView()
                                            }
                                    }
                                }
                            }
                        }
                        
                        HStack {
                            VStack(alignment: .leading) {
                                Text("Content Image")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                AsyncImage(
                                    url: URL(string: magazine.contentImage),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(1.0, contentMode: .fill)
                                            .frame(height: 250)
                                            .cornerRadius(8.0)
                                    }) {
                                        ProgressView()
                                    }
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Body Image")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                AsyncImage(
                                    url: URL(string: magazine.bodyImage),
                                    content: { image in
                                        image
                                            .resizable()
                                            .aspectRatio(1.0, contentMode: .fill)
                                            .frame(height: 250)
                                            .cornerRadius(8.0)
                                    }) {
                                        ProgressView()
                                    }
                            }
                            Spacer()
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                .onChange(of: magazine) { newValue in
                    title = newValue.title
                    subTitle = newValue.subTitle
                }
            } else {
                Text("No Content Here .. 😅")
            }
        }
        
    }
}

struct MagazineDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MagazineDetailView()
    }
}
