//
//  Appearance.swift
//  StickIt
//
//  Created by Alexander Rivera on 4/29/25.
//

import SwiftUI

enum Appearance: String, CaseIterable, Identifiable {
    case system
    case light
    case dark
    
    var id: String { self.rawValue }
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

struct AppearancePicker: View {
    @AppStorage("appearance") var appearance: Appearance = .system
    @Environment(\.colorScheme) private var scheme

    var body: some View {
        List {
            ForEach(Appearance.allCases, id: \.self) { option in
                HStack {
                    Text(option.rawValue.capitalized)
                    Spacer()
                    if option == appearance {
                        Image(systemName: "checkmark")
                            .foregroundColor(.accentColor)
                    }
                }
                .contentShape(Rectangle()) // Makes the whole row tappable
                .onTapGesture {
                    appearance = option
                }
            }
        }
        .navigationTitle("Theme")
        .listStyle(.insetGrouped)
        .preferredColorScheme(appearance.colorScheme == .none ? scheme : appearance.colorScheme)
    }
}

#Preview {
    AppearancePicker()
}
