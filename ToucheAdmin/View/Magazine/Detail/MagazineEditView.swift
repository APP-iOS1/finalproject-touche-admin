//
//  MagazineEditView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/13.
//

import SwiftUI
import Combine

final class MagazineEditViewModel: ObservableObject {
    @Published var title: String = ""
    @Published var subTitle: String = ""
    @Published var contentImage: NSImage?
    @Published var bodyImage: NSImage?
    @Published var isLoading: Bool = false
    // assigning properties
    @Published var canSaveState: Bool = false
    var cancellables = Set<AnyCancellable>()
    
    enum ImageCategory {
        case content
        case body
    }
    
    init() {
        $title
            .combineLatest($subTitle, $contentImage, $bodyImage)
            .map { title, subTitle, contentImage, bodyImage in
                return !title.isEmpty && !subTitle.isEmpty && contentImage != nil && bodyImage != nil
            }
            .assign(to: &$canSaveState)
    }
    
    func fecthNSImage(url: URL, category: ImageCategory) {
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .compactMap { (data: Data, response: URLResponse) -> NSImage? in
                guard let response = response as? HTTPURLResponse,
                      (200..<300).contains(response.statusCode),
                      let nsImage = NSImage(data: data) else { return nil }
                return nsImage
            }
            .sink { status in
                switch status {
                case .finished:
                    print("fetch done")
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [weak self] nsImage in
                switch category {
                case .content:
                    self?.contentImage = nsImage
                case .body:
                    self?.bodyImage = nsImage
                }
            }
            .store(in: &cancellables)

    }
}

// openPannel: [https://serialcoder.dev/text-tutorials/macos-tutorials/save-and-open-panels-in-swiftui-based-macos-apps/]
// drag and drop image: [https://www.hackingwithswift.com/quick-start/swiftui/how-to-support-drag-and-drop-in-swiftui]
struct MagazineEditView: View {
    @Binding var flow: Flow
    @StateObject var vm = MagazineEditViewModel()
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
                
                if magazineStore.magazine == nil {
                    HStack {
                        Spacer()
                        Button {
                            flow = .create
                        } label: {
                            Label("back", systemImage: "chevron.left")
                        }
                        Button {
                            // 새로운 메거진 생성
                            let magazine = Magazine(
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
                                // 읽기 모드
                                flow = .read
                                // upload end
                                vm.isLoading = false
                            }
                            
                        } label: {
                            Text("Save")
                        }
                        .disabled(!vm.canSaveState)
                    } // HSTACK(SAVE)
                }
                
                Form {
                    TextField(text: $vm.title, prompt: Text("Required.."), axis: .vertical) {
                        Text("Title")
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextField(text: $vm.subTitle, prompt: Text("Required.."), axis: .vertical) {
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
//                                AsyncImage(
//                                    url: URL(string: perfume.image450),
//                                    content: { image in
//                                        image
//                                            .resizable()
//                                            .aspectRatio(1.0, contentMode: .fill)
//                                            .frame(width: 100, height: 100)
//                                            .cornerRadius(8.0)
//                                    }) {
//                                        ProgressView()
//                                    }
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
                                vm.contentImage = nsImage
                            }
                        } label: {
                            if let contentImage = vm.contentImage {
                                Image(nsImage: contentImage)
                                    .resizable()
                                    .frame(width: 250, height: 250, alignment: .center)
                                    .cornerRadius(8.0)
                            } else {
                                RoundedRectangle(cornerRadius: 8.0)
                                    .fill(.quaternary)
                                    .frame(width: 250, height: 250)
                                    .overlay {
                                        Text("Select the image!\n**+**")
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
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Body Image")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        // drop or load from directory
                        Button {
                            if let url = showOpenPanel(),
                               let nsImage = NSImage(contentsOf: url) {
                                vm.bodyImage = nsImage
                            }
                        } label: {
                            if let bodyImage = vm.bodyImage {
                                Image(nsImage: bodyImage)
                                    .resizable()
                                    .frame(width: 250, height: 250, alignment: .center)
                                    .cornerRadius(8.0)
                            } else {
                                RoundedRectangle(cornerRadius: 8.0)
                                    .fill(.quaternary)
                                    .frame(width: 250, height: 250)
                                    .overlay {
                                        Text("Select the image!\n**+**")
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
                    
                    Spacer()
                } // HSTACK(IMAGES)
                
                Spacer()
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
                    .frame(width: 200, height: 200)
                    .background(Material.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20.0))
            }
        })
        .onChange(of: magazineStore.magazine) { magazine in
            flow = .read
        }
        .toolbar {
            if let magazine = magazineStore.magazine {
                ToolbarItem(placement: ToolbarItemPlacement.automatic) {
                    Button("done") {
                        flow = .read
                        // 기존 메거진 업데이트
                        let magazine = Magazine(
                            id: magazine.id,
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
                            // 읽기 모드
                            flow = .read
                            // upload end
                            vm.isLoading = false
                        }
                    }
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
