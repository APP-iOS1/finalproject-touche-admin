//
//  AccountView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/08.
//

import SwiftUI

/// 로그인(계정) 뷰
struct AccountView: View {
    // MARK: - PROPERTIES
    private let logo: [String] = ["T","o","u","c","h","é"]
    @Binding var isSignIn: Bool
    @EnvironmentObject var accountStore: AccountStore
    
    // MARK: - BODY
    var body: some View {
        HStack(spacing: 0) {
            
            sideBar()
            
            Divider()
            
            welcomeView()
            
        }
        .presentedWindowStyle(.hiddenTitleBar)
    }
}

private extension AccountView {
    /// Account View의 Sidebar 부분입니다.
    ///
    /// - 이메일 입력, 비밀번호 입력
    /// - 로그인, 비밀번호 찾기(개발 예정)
    func sideBar() -> some View {
        /// Input Layout
        VStack(alignment: .leading, spacing: 24.0) {
            /// Title
            Text("Welcome to Touché".localized)
                .font(.largeTitle)
                .fontWeight(.heavy)
            
            /// Name Field
            VStack(alignment: .leading, spacing: 8) {
                Text("User E-mail".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                TextField("Enter your E-mail..".localized, text: $accountStore.email)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(.quaternary)
                    .cornerRadius(8)
                    .textFieldStyle(.plain)
            }
            
            /// Password Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Password".localized)
                    .font(.body)
                    .foregroundColor(.secondary)
                SecureField("Enter your password..".localized, text: $accountStore.password)
                    .padding(.vertical, 10)
                    .padding(.horizontal)
                    .background(.quaternary)
                    .cornerRadius(8)
                    .textFieldStyle(.plain)
            }
            
//            Button {
//                // TODO: 비밀번호 찾기 ( Password Verification )
//            } label: {
//                Text("Forgot Password?")
//                    .font(.body)
//                    .foregroundColor(.secondary)
//                    .underline()
//            }
//            .buttonStyle(.plain)
            
            /// Sign In Action
            VStack(alignment: .leading, spacing: 16.0) {
                /// Sign In Button
                Button {
                    Task {
                        isSignIn = await accountStore.signInWithEmailPassword()
                    }
                } label: {
                    Text("Sign In".localized)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 40)
                        .clipShape(Capsule())
                        .background(
                            Capsule()
                                .stroke(.primary)
                        )
                }
                .buttonStyle(.plain)
                .disabled(!accountStore.isValid)
                
                /// Error Message
                Text(accountStore.errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }
            
            Spacer()
        } // VSTACK(SIDE BAR)
        .padding()
        .padding(.top, 30)
        .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
    }
    
    /// Account View의 도입부입니다.
    func welcomeView() -> some View {
        ZStack(alignment: .center) {
            // 1st background
            Group {
                LinearGradient(
                    stops: [
                        .init(color: .touchePink, location: 0.4),
                        .init(color: .toucheSky, location: 0.7),
                    ],
                    startPoint: .bottomLeading,
                    endPoint: .topTrailing
                )
                .blendMode(.normal)
                
                LinearGradient(
                    stops: [
                        .init(color: .toucheWhite.opacity(0.91), location: 0.05),
                        .init(color: .clear, location: 0.3),
                        .init(color: .touchePurple, location: 0.8),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .blendMode(.screen)
            }
            
            // 2nd background
            Group {
                Circle()
                    .fill(Color.toucheWhite)
                    .frame(width: 200)
                    .blur(radius: 60, opaque: false)
                    .offset(
                        x: -200,
                        y: -200
                    )
                
                Circle()
                    .fill(Color.touchePink)
                    .frame(width: 200)
                    .padding([.leading], 100)
                    .padding([.bottom], 100)
                    .blur(radius: 50, opaque: false)
                    .offset(
                        x: -10,
                        y: -10
                    )
                
                Circle()
                    .fill(Color.purple)
                    .saturation(0.7)
                    .frame(width: 300)
                    .blur(radius: 80, opaque: false)
                    .offset(
                        x: 300,
                        y: 300
                    )
            }
            
            // Main Title
            HStack(alignment: .center, spacing: 16.0) {
                ForEach(logo.indices, id: \.self) { i in
                    Text(logo[i])
                        .font(.system(size: 60, weight: .heavy, design: .default))
                        .fontWeight(.bold)
                        .foregroundColor(.toucheWhite)
                }
            } // HSTACK
        } // ZSTACK
        .frame(minWidth: 300, idealWidth: 600 ,maxWidth: .infinity, maxHeight: .infinity)
        .drawingGroup()
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AccountStore())
    }
}
