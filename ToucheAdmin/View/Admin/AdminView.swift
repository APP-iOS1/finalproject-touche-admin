//
//  AdminView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import SwiftUI

// layout reference: https://www.appcoda.com/navigationsplitview-swiftui/
/// 관리자 뷰
struct AdminView: View {
    // MARK: - PROPERTIES
    
    // only used in AdminView
    @Binding var isSignIn: Bool
    @State private var isAccountTapped: Bool = false
    @State private var dueID: Due.ID = .init(stringLiteral: "magazine")
    @State private var visibility: NavigationSplitViewVisibility = .all
    
    // magazine flow
    @State private var flow: Flow = .read
    // server task
    @State private var task: ServerTask = .network
    
    // sharing data
    @EnvironmentObject var accountStore: AccountStore
    @StateObject var magazineStore = MagazineStore()
    @StateObject var perfumeStore = PerfumeStore()
    @StateObject var apiStore = APIStore()
    
    // MARK: - BODY
    var body: some View {
        NavigationSplitView(
            columnVisibility: $visibility,
            sidebar: {
                sideBar()
                    .navigationSplitViewColumnWidth(min: 100.0, ideal: 200.0, max: 300)
            }, content: {
                switch dueID {
                    /// magazine
                case "magazine":
                    MagazineContentView(flow: $flow)
                        .navigationSplitViewColumnWidth(min: 150.0, ideal: 250.0, max: 350.0)
                    /// server
                default:
                    APIContentView(task: $task)
                        .navigationSplitViewColumnWidth(min: 150.0, ideal: 250.0, max: 350.0)
                }
            }, detail: {
                switch dueID {
                case "magazine":
                    switch flow {
                    case .read:
                        MagazineReadView(flow: $flow)
                            .navigationSplitViewColumnWidth(min: 200.0, ideal: 300.0, max: 400.0)
                    case .create:
                        MagazineRegisterView(flow: $flow)
                            .navigationSplitViewColumnWidth(min: 200.0, ideal: 300.0, max: 400.0)
                    case .edit:
                        MagazineEditView(flow: $flow)
                            .navigationSplitViewColumnWidth(min: 200.0, ideal: 300.0, max: 400.0)
                    }
                default:
                    switch task {
                    case .network:
                        APINetworkView()
                            .navigationSplitViewColumnWidth(min: 200.0, ideal: 300.0, max: 400.0)
                    case .log:
                        APILogView()
                            .navigationSplitViewColumnWidth(min: 200.0, ideal: 300.0, max: 400.0)
                    }
                }
            })
            .navigationSplitViewStyle(.balanced)
            .environmentObject(magazineStore)
            .environmentObject(perfumeStore)
            .environmentObject(apiStore)
            .alert("Account", isPresented: $isAccountTapped) {
                Button {
                    //
                } label: {
                    Text("Cancel")
                }
                .buttonStyle(.plain)
                
                Button {
                    accountStore.signOut()
                    isSignIn = false
                } label: {
                    Text("Sing Out")
                }
                .buttonStyle(.plain)
            }
    }
}

private extension AdminView {
    /// 관리자 뷰 사이드바
    func sideBar() -> some View {
        VStack(alignment: .center) {
            /// 계정 로그아웃 버튼
            Button {
                isAccountTapped = true
            } label: {
                VStack(alignment: .center, spacing: 8) {
                    Image("touche-logo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    
                    Text(accountStore.user?.email ?? "User")
                        .fontWeight(.semibold)
                        .lineLimit(1)
                }
            }
            .buttonStyle(.plain)
            .padding([.leading, .top], 4)
            
            Divider()
            
            /// 관리자 목록
            List(Due.allCases, selection: $dueID) { due in
                switch due {
                case .magazine:
                    Label(due.title, systemImage: due.systemName)
                case .server:
                    Label(due.title, systemImage: due.systemName)
                }
            }
            
            Spacer()
        }
    }
}

struct AdminView_Previews: PreviewProvider {
    static var previews: some View {
        AdminView(isSignIn: .constant(false))
            .environmentObject(AccountStore())
    }
}
