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
    @State private var name: String = ""
    @State private var password: String = ""
    private let logo: [String] = ["T","o","u","c","h","é"]
    var body: some View {
        let rect = getRect()
        let width = rect.width
        let height = rect.height
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 24.0) {
                Text("Welcome to Touché")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("User Name")
                        .font(.body)
                        .foregroundColor(.secondary)
                    TextField("Enter your name..", text: $name)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.toucheGray)
                        .cornerRadius(8)
                        .textFieldStyle(.plain)
                    
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Password")
                        .font(.body)
                        .foregroundColor(.secondary)
                    SecureField("Enter your password..", text: $password)
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .background(Color.toucheGray)
                        .cornerRadius(8)
                        .textFieldStyle(.plain)
                    
                }
                
                Button {
                    // seek password
                } label: {
                    Text("Forgot Password")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .underline()
                }
                
                .buttonStyle(.plain)
                
                VStack(alignment: .leading, spacing: 16.0) {
                    
                    Button {
                        // Sign In Action
                    } label: {
                        Text("Sign In")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .background(Color.white)
                            .cornerRadius(20)
                    }
                    .buttonStyle(.plain)
                    .shadow(color: .primary.opacity(0.2), radius: 2, x: 0, y: 0)
                    
                }
                
                Spacer()
            }
            .padding()
            .padding(.top, 30)
            .frame(width: width * 0.6 * 0.3)
            .background(Color.toucheWhite)
            
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
                    .position(CGPoint(x: width * 01, y: height * 0.1))
                    .blur(radius: 100, opaque: false)
                
                Circle()
                    .fill(Color.touchePink)
                    .frame(width: 200)
                    .padding([.leading], 100)
                    .padding([.bottom], 100)
                    .position(CGPoint(x: width * 0.1, y: height * 0.25))
                    .blur(radius: 100, opaque: false)
                
                Circle()
                    .fill(Color.purple)
                    .saturation(0.7)
                    .frame(width: 300)
                    .position(CGPoint(x: width * 0.35, y: height * 0.5))
                    .blur(radius: 80, opaque: false)
                
                HStack(alignment: .center, spacing: 16.0) {
                    ForEach(logo.indices, id: \.self) { i in
                        Text(logo[i])
                            .font(.system(size: 60, weight: .heavy, design: .default))
                            .fontWeight(.bold)
                            .foregroundColor(.toucheWhite)
                    }
                }
            } // ZSTACK
        }
        .ignoresSafeArea()
        .frame(width: width * 0.6, height: height * 0.6)
    }
}

struct AccountView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
