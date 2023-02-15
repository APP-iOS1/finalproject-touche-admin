//
//  AdminView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import SwiftUI

// layout reference: https://www.appcoda.com/navigationsplitview-swiftui/
struct AdminView: View {
    // only used in AdminView
    @Binding var isSignIn: Bool
    @State private var isAccountTapped: Bool = false
    @State private var dueID: Due.ID = .init(stringLiteral: "magazine")
    @State private var visibility: NavigationSplitViewVisibility = .all
    // sharing data
    @EnvironmentObject var accountStore: AccountStore
    @StateObject var magazineStore = MagazineStore()
    @StateObject var perfumeStore = PerfumeStore()
    @StateObject var apiStore = APIStore()
    
    // magazine flow
    @State private var flow: Flow = .read
    // server task
    @State private var task: ServerTask = .network
    
    var body: some View {
        let rect = getRect()
        let width = rect.width
        let height = rect.height
        NavigationSplitView(
            columnVisibility: $visibility,
            sidebar: {
                sideBar()
                    .navigationSplitViewColumnWidth(200.0)
            }, content: {
                switch dueID {
                    /// magazine
                case "magazine":
                    MagazineContentView(flow: $flow)
                        .navigationSplitViewColumnWidth(250.0)
                    /// server
                default:
                    APIContentView(task: $task)
                        .navigationSplitViewColumnWidth(250.0)
                }
            }, detail: {
                switch dueID {
                case "magazine":
                    switch flow {
                    case .read:
                        MagazineReadView(flow: $flow)
                    case .create:
                        MagazineRegisterView(flow: $flow)
                    case .edit:
                        MagazineEditView(flow: $flow)
                    }
                default:
                    switch task {
                    case .network:
                        APINetworkView()
                    case .log:
                        APILogView()
                    }
                }
            })
        .frame(width: width * 0.6, height: height * 0.6)
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
    func sideBar() -> some View {
        VStack(alignment: .center) {
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
