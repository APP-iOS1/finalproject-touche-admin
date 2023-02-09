//
//  AdminView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import SwiftUI

// layout reference: https://www.appcoda.com/navigationsplitview-swiftui/
struct AdminView: View {
    @Binding var isSignIn: Bool
    @State private var isAccountTapped: Bool = false
    @EnvironmentObject var accountStore: AccountStore
    @StateObject var magazineStore = MagazineStore()
    @State private var dueID: Due.ID = .init(stringLiteral: "magazine")
    @State private var visibility: NavigationSplitViewVisibility = .all
    
    enum Due: String, Identifiable, CaseIterable {
        case magazine
        case server
        
        var id: String { self.rawValue }
        var title: String { self.rawValue }
        var systemName: String {
            switch self {
            case .magazine: return "square.and.pencil"
            case .server: return "server.rack"
            }
        }
    }
    
    var body: some View {
        let rect = getRect()
        let width = rect.width
        let height = rect.height
        NavigationSplitView(columnVisibility: $visibility,
        sidebar: {
           sideBar()
            .onChange(of: dueID) { newValue in
                if newValue != "magazine" {
                    magazineStore.magazine = nil
                }
            }
            .navigationSplitViewColumnWidth(200.0)
        }, content: {
            switch dueID {
            /// magazine
            case "magazine":
                MagazineContentView()
                    .navigationSplitViewColumnWidth(250.0)
            /// server
            default:
                List(0..<10) { i in
                    Text("\(i) server")
                }
                .navigationSplitViewColumnWidth(250.0)
            }
        }, detail: {
            MagazineDetailView()
        })
            .frame(width: width * 0.6, height: height * 0.6)
            .navigationSplitViewStyle(.balanced)
            .environmentObject(magazineStore)
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
                    print("Tapped!")
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
