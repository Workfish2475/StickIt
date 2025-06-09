//
//  TipView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/28/25.
//

import StoreKit
import SwiftUI

struct TipView: View {
    private var productIDs: [String] = ["tip1", "tip2", "tip3"]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach (productIDs.indices, id: \.self) { index in
                    ProductView(id: productIDs[index])
                        .productViewStyle(.compact)
                }
            }
        }
        
        .navigationTitle("Tips")
    }
}



#Preview {
    TipView()
}
