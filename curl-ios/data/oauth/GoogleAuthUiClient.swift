//
//  GoogleAuthUiClient.swift
//  curl-ios
//
//  Created by Nadineenik on 09.10.2026.
//добавить в file-add package depencies -  https://github.com/google/GoogleSignIn-IOS
//
//

//import Foundation
//import GoogleSignIn
//import UIKit
//
//@MainActor
//final class GoogleAuthClient {
//    
//    func signIn() async throws -> String {
//        // Единственное место, где мы трогаем UIKit — прямо здесь
//        guard let presentingVC = Self.topViewController() else {
//            throw GoogleAuthError.noPresentingViewController
//        }
//        
//        return try await withCheckedThrowingContinuation { continuation in
//            GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC) { result, error in
//                if let error {
//                    continuation.resume(throwing: error)
//                    return
//                }
//                guard let idToken = result?.user.idToken?.tokenString else {
//                    continuation.resume(throwing: GoogleAuthError.missingIdToken)
//                    return
//                }
//                continuation.resume(returning: idToken)
//            }
//        }
//    }
//    
//    func restorePreviousSignIn() async -> String? {
//        await withCheckedContinuation { continuation in
//            GIDSignIn.sharedInstance.restorePreviousSignIn { user, _ in
//                continuation.resume(returning: user?.idToken?.tokenString)
//            }
//        }
//    }
//    
//    func signOut() {
//        GIDSignIn.sharedInstance.signOut()
//    }
//    
//    private static func topViewController() -> UIViewController? {
//        guard let scene = UIApplication.shared.connectedScenes
//            .compactMap({ $0 as? UIWindowScene })
//            .first(where: { $0.activationState == .foregroundActive }),
//              let root = scene.windows.first(where: { $0.isKeyWindow })?.rootViewController
//        else { return nil }
//        
//        var top = root
//        while let presented = top.presentedViewController {
//            top = presented
//        }
//        return top
//    }
//}
//
//enum GoogleAuthError: LocalizedError {
//    case missingIdToken
//    case noPresentingViewController
//    
//    var errorDescription: String? {
//        switch self {
//        case .missingIdToken: return "Google не вернул idToken"
//        case .noPresentingViewController: return "Нет активного окна для презентации"
//        }
//    }
//}
