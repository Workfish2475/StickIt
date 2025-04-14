//
//  SettingsView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/12/25.
//
import SwiftUI

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            Text("Settings")
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem (placement:.topBarTrailing) {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .symbolRenderingMode(.hierarchical)
                        }
                    }
                }
        }
    }
}

#Preview ("Settings") {
    SettingsView()
}
