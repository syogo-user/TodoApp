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
    
    var body: some View {
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
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .padding()
            
            Button {
                socialSignIn(provider: .apple)
            } label: {
                Image(R.image.apple.name)
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            .padding()
            
            Spacer()
        }
        .padding(.horizontal, 50)
        .padding(.top, 200)
    }
    
    private func socialSignIn(provider: AuthProvider) {
        Task {
            do {
                try await viewModel.socialSigIn(provider: provider)
                isSignIn = true
            } catch {
                
            }
        }
    }
}


#Preview {
    SignInView()
}
