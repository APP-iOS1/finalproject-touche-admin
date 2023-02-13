//
//  MagazineEditView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/13.
//

import SwiftUI

// openPannel: [https://serialcoder.dev/text-tutorials/macos-tutorials/save-and-open-panels-in-swiftui-based-macos-apps/]
// drag and drop image: [https://www.hackingwithswift.com/quick-start/swiftui/how-to-support-drag-and-drop-in-swiftui]
struct MagazineEditView: View {
    @Binding var flow: Flow
    @State private var title: String = ""
    @State private var subTitle: String = ""
    @State private var contentImage: NSImage?
    @State private var bodyImage: NSImage?
    @EnvironmentObject var perfumeStore: PerfumeStore
    @EnvironmentObject var magazineStore: MagazineStore
    var perfumes: [Perfume] {
        if let magazine = magazineStore.magazine {
            perfumeStore.fetchPerfumes(magazine.perfumeIds)
            return perfumeStore.selectedPerfumes
        } else {
            return perfumeStore.selectedPerfumes
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 20.0) {
                Text(Date.now.formatted())
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
                HStack {
                    Spacer()
                    Button {
                        // 모든 조건이 부합해야 저장기능 가능
                        guard !title.isEmpty && !subTitle.isEmpty,
                              let contentImage = contentImage,
                              let bodyImage = bodyImage else { return }
                        
                        // 새로운 메거진 생성
                        let magazine = Magazine(
                            title: title,
                            subTitle: subTitle,
                            contentImage: "",
                            bodyImage: "",
                            createdDate: Date.now.timeIntervalSince1970,
                            perfumeIds: perfumes.map { $0.perfumeId }
                        )
                        
                        Task {
                            // 메거진 서버에 저장
                            await magazineStore.createMagazine(magazine: magazine, selectedContentUImage: contentImage, selectedBodyUImage: bodyImage)
                            // 읽기 모드
                            flow = .read
                        }
                    } label: {
                        Text("Save")
                    }
                } // HSTACK(SAVE)
                
                Form {
                    TextField(text: $title, prompt: Text("Required.."), axis: .vertical) {
                        Text("Title")
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField(text: $subTitle, prompt: Text("Required.."), axis: .vertical) {
                        Text("Sub Title")
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } // FORM(TEXT FIELD)
                
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
                    } // SCROLL(PERFUMES)
                } // VSTACK(PERFUMES)
                .frame(height: 120)
                
                HStack(spacing: 30) {
                    VStack(alignment: .leading) {
                        Text("Content Image")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // drop or load from directory
                        Button {
                            if let url = showOpenPanel(),
                               let nsImage = NSImage(contentsOf: url) {
                                contentImage = nsImage
                            }
                        } label: {
                            if let contentImage = contentImage {
                                Image(nsImage: contentImage)
                                    .resizable()
                                    .frame(width: 250, height: 250, alignment: .center)
                                    .cornerRadius(8.0)
                            } else {
                                RoundedRectangle(cornerRadius: 8.0)
                                    .fill(.quaternary)
                                    .frame(width: 250, height: 250)
                                    .overlay {
                                        Text("Select the image!\n➕")
                                            .multilineTextAlignment(.center)
                                    }
                                
                            }
                        }
                        .buttonStyle(.plain)
                        .dropDestination(for: Data.self) { items, location in
                            if let item = items.first {
                                contentImage = NSImage(data: item)
                            }
                            
                            return true
                        }
                    } // VSTACK(CONTENT IMAGE)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Body Image")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // drop or load from directory
                        Button {
                            if let url = showOpenPanel(),
                               let nsImage = NSImage(contentsOf: url) {
                                bodyImage = nsImage
                            }
                        } label: {
                            if let bodyImage = bodyImage {
                                Image(nsImage: bodyImage)
                                    .resizable()
                                    .frame(width: 250, height: 250, alignment: .center)
                                    .cornerRadius(8.0)
                            } else {
                                RoundedRectangle(cornerRadius: 8.0)
                                    .fill(.quaternary)
                                    .frame(width: 250, height: 250)
                                    .overlay {
                                        Text("Select the image!\n➕")
                                            .multilineTextAlignment(.center)
                                    }
                            }
                        }
                        .buttonStyle(.plain)
                        .dropDestination(for: Data.self) { items, location in
                            if let item = items.first {
                                bodyImage = NSImage(data: item)
                            }
                            
                            return true
                        }
                    } // VSTACK(BODY IMAGE)
                    
                    Spacer()
                } // HSTACK(IMAGES)
                
                Spacer()
            } // VSTACK
            .padding()
        } // SCROLL
        .toolbar {
            ToolbarItem {
                Button {
                    flow = .create
                } label: {
                    Image(systemName: "chevron.left")
                }
                
            }
        }
    }
    
    private func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.jpeg, .png, .heic]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
}

struct MagazineEditView_Previews: PreviewProvider {
    static var previews: some View {
        MagazineEditView(flow: .constant(.edit))
            .environmentObject(PerfumeStore())
            .environmentObject(MagazineStore())
    }
}
