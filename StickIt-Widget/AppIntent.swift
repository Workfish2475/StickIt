//
//  AppIntent.swift
//  StickIt-Widget
//
//  Created by Alexander Rivera on 4/14/25.
//

import WidgetKit
import AppIntents
import SwiftData

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "StickIt-Widget"
    static var description: IntentDescription = IntentDescription("Select a note to display")

    @Parameter(title: "Selected Note", default: "")
    var noteId: String
}
