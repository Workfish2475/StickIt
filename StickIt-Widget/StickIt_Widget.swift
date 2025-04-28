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

struct StickIt_WidgetEntryView: View {
    var entry: NoteProvider.Entry

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                headerView()

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(name: entry.configuration.noteItem!.color))

                    Markdown(markdownText: .constant(" \(entry.configuration.noteItem!.content)"), limit: false)
                        .padding()
                }
                
                .frame(maxWidth: .infinity)
                .frame(height: geo.size.height - 50, alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .foregroundStyle(.white)
        .containerBackground(Color(name: entry.configuration.noteItem!.color).opacity(0.8), for: .widget)
        .widgetURL(URL(string: "stickit//\(entry.configuration.noteItem!.id)"))
    }
    
    @ViewBuilder
    func headerView() -> some View {
        Text("\(entry.configuration.noteItem!.name)")
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
        
        Text("Last modified \(entry.date.formatted(.dateTime.hour().minute()))")
            .font(.caption)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)
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

#Preview(as: .systemExtraLarge) {
    StickIt_Widget()
} timeline: {
    SimpleEntry(date: .now, configuration: .demo)
}

