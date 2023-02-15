//
//  DownloadingImageVIewModel.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//

import SwiftUI
import Combine

final class DownloadingImageViewModel: ObservableObject {
    @Published var image: NSImage? = nil
    @Published var isLoading: Bool = false
    
    var cancellables = Set<AnyCancellable>()
    let manager = PhotoModelFileManager.instance
    
    let urlString: String
    let key: String
    
    init(urlString: String, key: String) {
        self.urlString = urlString
        self.key = key
        self.getImage()
    }
    
    func getImage() {
        if let savedImage = manager.get(key: key) {
            self.image = savedImage
            print("Getting saved image!")
        } else {
            print("Downloading image now!")
            downloadImage()
        }
    }
    
    func downloadImage() {
        isLoading = true
        guard let url = URL(string: urlString) else {
            isLoading = false
            return
        }
        
        URLSession.shared.dataTaskPublisher(for: url)
            .map { NSImage(data: $0.data) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (_) in
                self?.isLoading = false
            } receiveValue: { [weak self] returnedImage in
                guard let self = self,
                      let image = returnedImage else { return }
                self.image = image
                self.manager.add(key: self.key, value: image)
            }
            .store(in: &cancellables)

    }
}
