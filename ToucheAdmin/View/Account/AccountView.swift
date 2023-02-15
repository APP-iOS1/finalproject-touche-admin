//
//  AccountView.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/08.
//

import SwiftUI

// 1. Navigation SplitView 사용 금지 -> 커스텀한 Hstack, Vstack으로 대체
// 2. 컬러디자인 사용.
struct AccountView: View {
    @Binding var isSignIn: Bool
    @EnvironmentObject var accountStore: AccountStore
    
    private let logo: [String] = ["T","o","u","c","h","é"]
    var body: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24.0) {
                Text("Welcome to Touché")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("User Name")
                        .font(.body)
                        .foregroundColor(.secondary)
                    TextField("Enter your name..", text: $accountStore.email)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .foregroundColor(.primary)
                        .background(.quaternary)
                        .cornerRadius(8)
                        .textFieldStyle(.plain)
                    
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.body)
                        .foregroundColor(.secondary)
                    SecureField("Enter your password..", text: $accountStore.password)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(.quaternary)
                        .cornerRadius(8)
                        .textFieldStyle(.plain)
                    
                }
                
                // TODO: 비밀번호 찾기
                //                Button {
                //                    // seek password
                //                } label: {
                //                    Text("Forgot Password?")
                //                        .font(.body)
                //                        .foregroundColor(.secondary)
                //                        .underline()
                //                }
                
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 16.0) {
                    
                    Button {
                        Task {
                            isSignIn = await accountStore.signInWithEmailPassword()
                        }
                    } label: {
                        Text("Sign In")
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
                    
                    Text(accountStore.errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                    
                }
                
                Spacer()
            }
            .padding()
            .padding(.top, 30)
            .frame(minWidth: 300, idealWidth: 400, maxWidth: 500)
            
            Divider()
            
            // Gradient...
            ZStack(alignment: .center) {
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
                
                HStack(alignment: .center, spacing: 16.0) {
                    ForEach(logo.indices, id: \.self) { i in
                        Text(logo[i])
                            .font(.system(size: 60, weight: .heavy, design: .default))
                            .fontWeight(.bold)
                            .foregroundColor(.toucheWhite)
                    }
                }
            } // ZSTACK
            .frame(minWidth: 300, idealWidth: 600 ,maxWidth: .infinity, maxHeight: .infinity)
            .drawingGroup()
        }
        .presentedWindowStyle(.hiddenTitleBar)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AccountStore())
    }
}
