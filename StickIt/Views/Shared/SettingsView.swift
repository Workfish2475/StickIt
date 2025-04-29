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
    @AppStorage("appearance") private var appearance: Appearance = .system
    
    var body: some View {
        NavigationStack {
            List {
                Section ("General") {
                    NavigationLink(destination: AppearancePicker()) {
                        Label("Theme", systemImage: "moon")
                    }
                }
                
                Section ("App info") {
                    NavigationLink(destination: TipView()) {
                        Label("Tip", systemImage: "dollarsign")
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
        
        .preferredColorScheme(appearance.colorScheme)
    }
    
    func setupMail() -> Void {
        let mailURL = URL(string: "mailto:alexander2475@icloud.com")!
        if UIApplication.shared.canOpenURL(mailURL) {
            UIApplication.shared.open(mailURL, options: [:], completionHandler: nil)
         }
    }
    
    func openSubPage() -> Void {
        dismiss()
    }
}

struct WhatsNew: View {
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                item("iCloud Sync", "Sync your notes automatically across devices.", "icloud.fill")
                item("Home Screen Widgets", "Access notes quickly from your Home Screen.", "square.grid.2x2.fill")
                item("Pinnable Notes", "Keep important notes at the top of your list.", "pin.fill")
                item("Customizable Notes", "Style your notes with fonts and colors.", "paintpalette.fill")
            }
            
            .padding(.top, 24)
            
            Button {
                dismiss()
            } label: {
                Label("Done", systemImage: "checkmark")
                    .fontWeight(.bold)
                    .frame(maxWidth: .infinity)
            }
            
            .buttonStyle(.borderedProminent)
            .padding(.top, 32)
        }
        
        .padding(.horizontal)
        .background(Color(uiColor: .secondarySystemBackground))
        .navigationTitle("What's New")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func item(_ title: String, _ description: String, _ systemImage: String) -> some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: systemImage)
                .font(.system(size: 28))
                .foregroundStyle(.blue.gradient)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green.gradient)
                .font(.title3)
        }
        
        .padding()
        .background(Color(uiColor: .tertiarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview ("Settings") {
    SettingsView()
}

#Preview ("WhatsNew") {
    WhatsNew()
}
