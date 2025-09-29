//
//  LoadingView.swift
//  TH75
//
//  Created by IGOR on 29/09/2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {

        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack {
                
                Image("logo75")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 130)
            }
            
            VStack {
                
                Spacer()
                
                ProgressView()
                    .padding(40)
            }
        }
    }
}

#Preview {
    LoadingView()
}
