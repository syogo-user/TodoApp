//
//  SignInView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/12.
//

import SwiftUI

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModelImpl()
    
    var body: some View {
        Button(action: {
            Task {
                do {
                    try await viewModel.socialSigIn(provider: .google)
                } catch {
                    
                }
            }
        }) {
            Text("GoogleSignIn")
        }
    }
}

#Preview {
    SignInView()
}
