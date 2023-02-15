//
//  MagazineRegisterView.swift
//  ToucheAdmin
//
//  Created by Yooj on 2023/02/07.
//

import SwiftUI

struct MagazineRegisterView: View {
    @Binding var flow: Flow
    @EnvironmentObject var perfumeStore: PerfumeStore
    @EnvironmentObject var magazinestore: MagazineStore
    @State private var layout: Layout = .grid
    
    enum Layout: String, Identifiable, CaseIterable {
        var id: String { self.rawValue }
        case grid
        case list
    }
    
    /// perfumes 데이터를 (brand, perfumes)로 그룹핑한 데이터
    var items: [(brand: String, perfumes: [Perfume])] {
        return Dictionary(grouping: perfumeStore.perfumes) { perfume in
            return perfume.brandName
        }
        .map { (key: String, value: [Perfume]) -> (brand: String, perfumes: [Perfume]) in
            (key, value)
        }
        .sorted { left, right in
            left.brand < right.brand
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button {
                flow = .read
            } label: {
                Label("hide", systemImage: "chevron.left")
                    .labelStyle(.iconOnly)
            }
            .buttonStyle(.plain)
            
            HStack(alignment: .bottom, spacing: 10) {
                Text("Select the perfumes")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("\(perfumeStore.selectedPerfumes.count) / 10")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("Clear") {
                    perfumeStore.clearPerfume()
                }
                .disabled(perfumeStore.isNextButtonDisabled)
                
                Button("Next") {
                    flow = .edit
                }
                .disabled(perfumeStore.isNextButtonDisabled)
            } // HSTACK
            
            if !perfumeStore.isNextButtonDisabled {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .center, spacing: 12) {
                        ForEach(perfumeStore.selectedPerfumes, id: \.perfumeId) { perfume in
                            Button {
                                perfumeStore.popPerfume(perfume)
                            } label: {
                                DownloadingImageView(urlString: perfume.image450, key: perfume.perfumeId)
                                    .frame(width: 80, height: 80, alignment: .center)
                                    .clipShape(RoundedRectangle(cornerRadius: 8.0))
                                    .overlay(alignment: .topTrailing, content: {
                                        Image(systemName: "xmark.circle")
                                            .font(.title3)
                                            .foregroundStyle(
                                                AngularGradient(
                                                    colors: [.touchePink, .toucheBlue, .touchePurple, .toucheSky],
                                                    center: .center
                                                )
                                            )
                                            .padding(4)
                                    })
                                    .shadow(color: .primary.opacity(0.2) ,radius: 1)
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
                            .buttonStyle(.plain)
                        }
                    }
                } // SCROLL
                .transition(.slide.combined(with: .opacity).animation(.easeIn))
                .frame(height: 90)
            }
            
            switch layout {
            case .grid:
                ScrollView {
                    ForEach(items, id: \.brand) { (item: (brand: String, perfumes: [Perfume])) in
                        LazyVStack(alignment: .leading, spacing: 6.0) {
                            Text(item.brand)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(
                                columns: .init(repeating: .init(.flexible(), spacing: 12), count: 6),
                                spacing: 0.0
                            ) {
                                ForEach(item.perfumes, id: \.perfumeId) { perfume in
                                    Button {
                                        perfumeStore.checkPerfume(perfume) ?
                                        perfumeStore.popPerfume(perfume) :
                                        perfumeStore.selectPerfume(perfume)
                                    } label: {
                                        DownloadingImageView(urlString: perfume.image450, key: perfume.perfumeId)
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
                                            .padding(4)
                                            .padding(.top, 12)
                                            .overlay(alignment: .topTrailing, content: {
                                                if perfumeStore.checkPerfume(perfume) {
                                                    Image(systemName: "checkmark.seal")
                                                        .font(.title3)
                                                        .foregroundStyle(
                                                            AngularGradient(
                                                                colors: [.touchePink, .toucheBlue, .touchePurple, .toucheSky],
                                                                center: .center
                                                            )
                                                        )
                                                        .padding(.top, 20.0)
                                                        .padding(.trailing, 8.0)
                                                }
                                            })
                                            .shadow(color: .primary.opacity(0.2) ,radius: 1)
                                    }  // IMAGE
                                    .buttonStyle(.plain)
                                    .onHover { hovering in
                                        perfumeStore.hasHoverPerfume(perfume, hovering: hovering)
                                    }
                                } // LOOP
                            } // VGRID
                            
                            Divider()
                        } // LAZYVSTACK
                    } // LOOP
                } // SCROLL
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(.tertiary)
                        .frame(height: 1)
                        .shadow(color: .primary.opacity(0.2), radius: 4, x: 0, y: 4)
                }
            case .list:
                List {
                    ForEach(items, id: \.brand) { (item: (brand: String, perfumes: [Perfume])) in
                        Section(item.brand) {
                            ForEach(item.perfumes, id: \.perfumeId) { (perfume: Perfume) in
                                Button {
                                    perfumeStore.checkPerfume(perfume) ?
                                    perfumeStore.popPerfume(perfume) :
                                    perfumeStore.selectPerfume(perfume)
                                    
                                } label: {
                                    HStack(alignment: .center) {
                                        Image(systemName: perfumeStore.checkPerfume(perfume) ? "checkmark.seal" : "seal")
                                            .font(.title3)
                                            .foregroundStyle(
                                                AngularGradient(
                                                    colors: [.touchePink, .toucheBlue, .touchePurple, .toucheSky],
                                                    center: .center
                                                )
                                            )
                                            .padding(2)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .padding(.trailing, 2)
                                            .opacity(perfumeStore.checkPerfume(perfume) ? 1 : 0.4)
                                        
                                        DownloadingImageView(urlString: perfume.image450, key: perfume.perfumeId)
                                            .frame(width: 50, height: 50)
                                            .cornerRadius(8.0)
                                            .shadow(color: .primary.opacity(0.2) ,radius: 1)
                                        
                                        Text(perfume.displayName)
                                            .font(.headline)
                                        
                                    } // HSTACK
                                } // BUTTON
                                .buttonStyle(.plain)
                                .listRowSeparator(Visibility.visible, edges: [VerticalEdge.Set.bottom])
                            } // LOOP
                        } // SECTION
                    } // LOOP
                } // LIST
            }
        } // VSTACK
        .padding()
        .onChange(of: magazinestore.magazine) { _ in
            flow = .read
        }
        .toolbar {
            ToolbarItem(placement: ToolbarItemPlacement.principal) {
                Picker("Layout", selection: $layout) {
                    ForEach(Layout.allCases) {
                        Text($0.rawValue).tag($0)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}

struct MagazineRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        MagazineRegisterView(flow: .constant(.create))
            .environmentObject(PerfumeStore())
            .environmentObject(MagazineStore())
    }
}
