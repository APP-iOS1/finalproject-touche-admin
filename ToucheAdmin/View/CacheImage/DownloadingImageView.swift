//
//  DownloadingImageView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/14.
//

import SwiftUI

struct DownloadingImageView: View {
    @StateObject var loader: DownloadingImageViewModel
    
    init(urlString: String, key: String) {
        _loader = StateObject(wrappedValue: DownloadingImageViewModel(urlString: urlString, key: key))
    }
    
    var body: some View {
        ZStack {
            if loader.isLoading {
                ProgressView()
            } else if let image = loader.image {
                Image(nsImage: image)
                    .resizable()
                    .scaledToFit()
            }
        }
    }
}
