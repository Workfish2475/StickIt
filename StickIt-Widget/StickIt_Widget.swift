//
//  StickIt_Widget.swift
//  StickIt-Widget
//
//  Created by Alexander Rivera on 4/14/25.
//

import WidgetKit
import SwiftUI

struct NoteProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let entry = SimpleEntry(date: .now, configuration: configuration)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct StickIt_WidgetEntryView : View {
    var entry: NoteProvider.Entry

    var body: some View {
        VStack (alignment: .leading) {
            Text("\(entry.configuration.noteItem!.name)")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Last modified \(entry.date.formatted(.dateTime.hour().minute()))")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(.init("\(entry.configuration.noteItem!.content)"))
                .multilineTextAlignment(.leading)
                .font(.system(size: 16, weight: .regular, design: .default))
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(name: entry.configuration.noteItem!.color))
                )
            
            Spacer()
        }
        
        .foregroundStyle(.white)
        .containerBackground(Color(name: entry.configuration.noteItem!.color).opacity(0.8), for: .widget)
    }
}

struct StickIt_Widget: Widget {
    let kind: String = "StickIt_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: NoteProvider()
        ) { entry in
            StickIt_WidgetEntryView(entry: entry)
                .modelContainer(for: [Note.self])
        }
        
        .description("Sticky notes for your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var demo: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.noteItem = .placeholder
        return intent
    }
}

#Preview(as: .systemLarge) {
    StickIt_Widget()
} timeline: {
    SimpleEntry(date: .now, configuration: .demo)
}

