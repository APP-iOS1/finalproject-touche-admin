//
//  MagazineEditView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/13.
//

import SwiftUI

/// Magazine 수정 / 등록 뷰
///
/// **참고링크 목록**
///
/// - [openPannel](https://serialcoder.dev/text-tutorials/macos-tutorials/save-and-open-panels-in-swiftui-based-macos-apps/)
/// - [drag and drop image](https://www.hackingwithswift.com/quick-start/swiftui/how-to-support-drag-and-drop-in-swiftui)
struct MagazineEditView: View {
    @Binding var flow: Flow
    @StateObject var vm = MagazineEditViewModel()
    @EnvironmentObject var perfumeStore: PerfumeStore
    @EnvironmentObject var magazineStore: MagazineStore
    
    var perfumes: [Perfume] {
        if let magazine = magazineStore.magazine, magazineStore.status == .create {
            perfumeStore.fetchPerfumes(magazine.perfumeIds)
            return perfumeStore.selectedPerfumes
        } else {
            return perfumeStore.selectedPerfumes
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40.0) {
                /// Date
                Text(Date.now.formatted())
                    .font(.footnote)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                
                /// magazine 등록 버튼, 모든 데이터들이 입력되어야 등록가능
                HStack {
                    Spacer()
                    Button {
                        // 새로운 메거진 생성
                        let magazine = Magazine(
                            id: magazineStore.magazine == nil ? UUID().uuidString : magazineStore.magazine!.id,
                            title: vm.title,
                            subTitle: vm.subTitle,
                            contentImage: "",
                            bodyImage: "",
                            createdDate: Date.now.timeIntervalSince1970,
                            perfumeIds: perfumes.map { $0.perfumeId }
                        )
                        
                        Task {
                            // upload start
                            vm.isLoading = true
                            // 메거진 서버에 저장
                            await magazineStore.createMagazine(magazine: magazine, selectedContentUImage: vm.contentImage, selectedBodyUImage: vm.bodyImage)
                            vm.manager.add(key: "\(magazine.id)Content", value: vm.contentImage!)
                            vm.manager.add(key: "\(magazine.id)Body", value: vm.bodyImage!)
                            // 읽기 모드
                            flow = .read
                            // upload end
                            vm.isLoading = false
                            magazineStore.status = .create
                        }
                        
                    } label: {
                        Text(magazineStore.magazine == nil ? "Save".localized : "Done".localized)
                    } // BUTTON(MAGAZINE)
                    .disabled(!vm.canSaveState)
                }
                    
                /// 텍스트 필드들
                Form {
                    TextField(text: $vm.title, prompt: Text("Required..".localized), axis: .vertical) {
                        Text("Title".localized)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField(text: $vm.subTitle, prompt: Text("Required..".localized), axis: .vertical) {
                        Text("Sub Title".localized)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                } // FORM(TEXT FIELD)
                
                VStack(alignment: .leading) {
                    
                    HStack(spacing: 16.0) {
                        /// 타이틀
                        Text("Perfumes".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        /// 향수 고르기 버튼
                        Button {
                            flow = .create
                            magazineStore.status = .edit
                        } label: {
                            Label("Perfume Pick".localized, systemImage: "chevron.left")
                        }
                    } // HSTACK
                    
                    /// 향수 스크롤뷰
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
                                    } // IMAGEVIEW
                            } // LOOP
                        } // LAZYHSTACK(PERFUMES)
                    } // SCROLL(PERFUMES)
                } // VSTACK(PERFUMES)
                .frame(height: 120)
                
                /// 이미지 업로드
                VStack(alignment: .leading) {
                    Text("Content Image".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // drop or load from directory
                    Button {
                        if let url = vm.showOpenPanel(),
                           let nsImage = NSImage(contentsOf: url) {
                            vm.contentImage = nsImage
                        }
                    } label: {
                        if let contentImage = vm.contentImage {
                            Image(nsImage: contentImage)
                                .resizable()
                                .frame(width: 300, height: 300, alignment: .center)
                                .cornerRadius(8.0)
                        } else {
                            RoundedRectangle(cornerRadius: 8.0)
                                .fill(.quaternary)
                                .frame(width: 300, height: 300)
                                .overlay {
                                    Text("Select the image!".localized+"\n+")
                                        .multilineTextAlignment(.center)
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .dropDestination(for: Data.self) { items, location in
                        if let item = items.first {
                            vm.contentImage = NSImage(data: item)
                        }
                        
                        return true
                    }
                } // VSTACK(CONTENT IMAGE)
                
                VStack(alignment: .leading) {
                    /// 타이틀
                    Text("Body Image".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // drop or load from directory
                    Button {
                        if let url = vm.showOpenPanel(),
                           let nsImage = NSImage(contentsOf: url) {
                            vm.bodyImage = nsImage
                        }
                    } label: {
                        if let bodyImage = vm.bodyImage {
                            Image(nsImage: bodyImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(8.0)
                        } else {
                            RoundedRectangle(cornerRadius: 8.0)
                                .fill(.quaternary)
                                .frame(width: 300, height: 300)
                                .overlay {
                                    Text("Select the image!".localized + "\n+")
                                        .multilineTextAlignment(.center)
                                }
                        }
                    }
                    .buttonStyle(.plain)
                    .dropDestination(for: Data.self) { items, location in
                        if let item = items.first {
                            vm.bodyImage = NSImage(data: item)
                        }
                        
                        return true
                    }
                } // VSTACK(BODY IMAGE)
                
            } // VSTACK
            .padding()
        } // SCROLL
        .onAppear {
            switch flow {
            case .edit:
                if let magazine = magazineStore.magazine,
                   let contentImageURL = URL(string: magazine.contentImage),
                   let bodyImageURL = URL(string: magazine.bodyImage) {
                    vm.title = magazine.title
                    vm.subTitle = magazine.subTitle
                    vm.fecthNSImage(url: contentImageURL, category: .content)
                    vm.fecthNSImage(url: bodyImageURL, category: .body)
                    // images
                    // url -> download -> NSImage
                }
            default:
                vm.title = ""
                vm.subTitle = ""
                vm.contentImage = nil
                vm.bodyImage = nil
            }
        }
        .overlay(content: {
            if vm.isLoading {
                ProgressView()
                    .frame(width: 100, height: 100)
                    .background(Material.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
            }
        })
        .onChange(of: magazineStore.magazine) { magazine in
            flow = .read
        }
    }
}

struct MagazineEditView_Previews: PreviewProvider {
    static var previews: some View {
        MagazineEditView(flow: .constant(.edit))
            .environmentObject(PerfumeStore())
            .environmentObject(MagazineStore())
    }
}
