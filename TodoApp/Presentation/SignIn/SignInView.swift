//
//  SignInView.swift
//  TodoApp
//
//  Created by 小野寺祥吾 on 2024/01/12.
//

import SwiftUI
import Amplify

struct SignInView: View {
    @StateObject private var viewModel = SignInViewModelImpl()
    @AppStorage("isSignIn") var isSignIn = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                Text(R.string.localizable.appName())
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.accentColor)
                    .padding(.bottom, 50)
                
                Button {
                    socialSignIn(provider: .google)
                } label: {
                    Image(R.image.google.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .padding()
                
                Button {
                    socialSignIn(provider: .apple)
                } label: {
                    Image(R.image.apple.name)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                }
                .padding()
                
                Spacer()
            }
            .padding(.horizontal, 50)
            .padding(.top, 200)
            if isLoading {
                ProgressView()
            }
        }
    }
    
    private func socialSignIn(provider: AuthProvider) {
        Task {
            do {
                isLoading = true
                try await viewModel.socialSigIn(provider: provider)
                isSignIn = true
                isLoading = false
            } catch {
                isLoading = false
            }
        }
    }
}


#Preview {
    SignInView()
}
