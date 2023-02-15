//
//  MagazineEditViewModel.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/15.
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
    
    /// 맥 디렉토리 접근
    ///
    /// 원하는 사진 데이터( jpeg, png, heic) 만 불러올 수 있음.
    func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.jpeg, .png, .heic]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
}
