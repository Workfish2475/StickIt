//
//  SettingsView.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/12/25.
//
import SwiftUI
import StoreKit

struct SettingsView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section ("General") {
                    Label("Theme", systemImage: "moon")
                    Label("Font", systemImage: "textformat")
                }
                
                Section ("App info") {
                    NavigationLink(destination: ProView()) {
                        Label("Tip", systemImage: "dollarsign")
                    }
                    
                    NavigationLink(destination: WhatsNew()) {
                        Label("What's new", systemImage: "sparkles")
                    }
                }
                
                Section("Help") {
                    Label("Contact", systemImage: "envelope")
                        .onTapGesture {
                            setupMail()
                        }
                    
                    Label("Website", systemImage: "safari")
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem (placement:.topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.gray)
                    }
                }
            }
        }
    }
    
    func setupMail() -> Void {
        let mailURL = URL(string: "mailto:alexander2475@icloud.com")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
         }
    }
    
    func openSubPage() -> Void {
        dismiss()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            SubscriptionStoreView(groupID: "21672814", visibleRelationships: .all)
        }
    }
}

struct WhatsNew: View {
    var body: some View {
        List {
            item("iCloud Sync", "Sync with iCloud across devices", "icloud.fill")
            item("Home Screen Widgets", "Sync with iCloud across devices", "gear")
            item("Pinnable Notes", "Sync with iCloud across devices", "pin.fill")
            item("Customizable Notes", "Sync with iCloud across devices", "note")
        }
        
        .navigationTitle("What's New")
    }
    
    func item(_ itemStr: String, _ itemDesc: String, _ itemImg: String) -> some View {
        HStack (alignment: .center) {
            Image(systemName: itemImg)
                .foregroundStyle(.blue.gradient)
            
            VStack (alignment: .leading) {
                Text(itemStr)
                    .font(.headline)
                Text(itemDesc)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green.gradient)
        }
    }
}

#Preview ("Settings") {
    SettingsView()
}

#Preview ("WhatsNew") {
    WhatsNew()
}
