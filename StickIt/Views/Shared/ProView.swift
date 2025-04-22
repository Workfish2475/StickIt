//
//  ProView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/19/25.
//

import SwiftUI
import StoreKit

struct ProView: View {
    
    
    var body: some View {
        SubscriptionStoreView(groupID: "21672814", visibleRelationships: .all)
            
    }
}

#Preview ("ProView") {
    ProView()
}
