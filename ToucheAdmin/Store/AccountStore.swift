//
//  AccountStore.swift
//  ToucheAdmin
//
//  Created by james seo on 2023/02/09.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

/// 사용자 계정 정보 처리클래스
///
/// - Source Code from Firebase team : [link](https://github.com/FirebaseExtended/firebase-video-samples/blob/main/fundamentals/apple/auth-gettingstarted/final/Favourites/Shared/Auth/AuthenticationViewModel.swift)
@MainActor
class AccountStore: ObservableObject {
    private let database = Firestore.firestore()
    
    @Published var email = ""
    @Published var password = ""
    @Published var flow: AuthenticationFlow = .login
    @Published var isValid  = false
    @Published var authenticationState: AuthenticationState = .unauthenticated
    @Published var errorMessage = ""
    @Published var user: User?
    
    enum AuthenticationState {
        case unauthenticated
        case authenticating
        case authenticated
    }
    
    enum AuthenticationFlow {
        case login
        case signUp
    }
    
    init() {
        registerAuthStateHandler()
        
        $flow
            .combineLatest($email, $password)
            .map { flow, email, password in
                flow == .login || !(email.isEmpty || password.isEmpty)
            }
            .assign(to: &$isValid)
    }
    
    private var authStateHandler: AuthStateDidChangeListenerHandle?
    
    /// 사용자가 로그인 했는지 여부를 파악하는 함수
    func registerAuthStateHandler() {
        if authStateHandler == nil {
            authStateHandler = Auth.auth().addStateDidChangeListener { auth, user in
                self.user = user
                self.authenticationState = user == nil ? .unauthenticated : .authenticated
            }
        }
    }
    
    /// 로그인과 회원가입상태를 스위치하는 함수
    func switchFlow() {
        flow = flow == .login ? .signUp : .login
        errorMessage = ""
    }
    
    /// 모든 정보 초기화하는 함수
    func reset() {
        flow = .login
        email = ""
        password = ""
    }
}

// MARK: - Email and Password Authentication
extension AccountStore {
    /// Email과 Password로 로그인하는 함수
    func signInWithEmailPassword() async -> Bool {
        authenticationState = .authenticating
        
        do {
            /// 로그인처리
            let result = try await Auth.auth().signIn(withEmail: self.email, password: self.password)
            /// 만약 계정이 관리자용 계정이라면 통과
            if try await checkAdmin(result) {
                return true
            } else {
                /// 아니라면 로그아웃 및 관리자화면 진입 불가
                signOut()
                self.errorMessage = "It's not a Admin Account.!"
                self.reset()
                return false
            }
        }
        catch  {
            print(error)
            errorMessage = error.localizedDescription
            authenticationState = .unauthenticated
            return false
        }
    }
    
    /// 로그인한 계정이 관리자인지 아닌지 판단하는 함수
    ///
    /// - Firestore에서 Admin collection에 저장되어 있는 계정과 일치하는 계정이 있다면 통과
    private func checkAdmin(_ result: AuthDataResult) async throws -> Bool {
        let snapshot = try await database.collection("Admin").getDocuments()
        let admins = snapshot.documents.compactMap { $0.data()["id"] as? String }
        return admins.contains(result.user.uid)
    }
    
    /// 로그아웃하는 함수
    func signOut() {
        do {
            try Auth.auth().signOut()
        }
        catch {
            print(error)
            errorMessage = error.localizedDescription
        }
    }
}
