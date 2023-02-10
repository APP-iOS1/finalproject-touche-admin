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
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
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
                    flow = .read
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
                                AsyncImage(url: URL(string: perfume.heroImage)) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
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
                                } placeholder: {
                                    ProgressView()
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                } // SCROLL
                .transition(.slide.combined(with: .opacity).animation(.easeIn))
                .frame(height: 90)
            }
            
            ScrollView {
                LazyVGrid(
                    columns: .init(repeating: .init(.flexible(), spacing: 12), count: 6),
                    spacing: 0.0
                ) {
                    ForEach(perfumeStore.perfumes, id: \.perfumeId) { perfume in
                        Button {
                            perfumeStore.checkPerfume(perfume) ?
                            perfumeStore.popPerfume(perfume) :
                            perfumeStore.selectPerfume(perfume)
                        } label: {
                            AsyncImage(url: URL(string: perfume.heroImage)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
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
                            } placeholder: {
                                ProgressView()
                            } // IMAGE
                            
                        }
                        .buttonStyle(.plain)
                        .onHover { hovering in
                            perfumeStore.hasHoverPerfume(perfume, hovering: hovering)
                        }
                    } // LOOP
                }
            } // SCROLL
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.tertiary)
                    .frame(height: 1)
                    .shadow(color: .primary.opacity(0.2), radius: 4, x: 0, y: 4)
            }
        } // VSTACK
        .padding()
    }
}

struct MagazineRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        MagazineRegisterView(flow: .constant(.create))
            .environmentObject(PerfumeStore())
    }
}
