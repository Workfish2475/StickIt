//
//  StickIt_Widget.swift
//  StickIt-Widget
//
//  Created by Alexander Rivera on 4/14/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: AppIntentTimelineProvider {
    var container: ModelContext {
        let context: ModelContext
        
        do {
            let container = try ModelContainer(for: Note.self, configurations: .init(isStoredInMemoryOnly: false))
            context = ModelContext(container)
        } catch {
            fatalError("Error creating ModelContainer: \(error)")
        }
        
        return context
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []
        
        let entry = SimpleEntry(date: .now, configuration: configuration)
        entries.append(entry)

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct StickIt_WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack (alignment: .leading) {
            Text("Sample Text")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Last modified \(entry.date.formatted(.dateTime.hour().minute()))")
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(.init("Some note text goes here. Could be something like a list: \n* Item 1\n* Item 2\n* Item 3"))
                .multilineTextAlignment(.leading)
                .font(.system(size: 16, weight: .regular, design: .default))
                .padding(.top, 2)
            
            Spacer()
        }
        
        .foregroundStyle(.white)
        .containerBackground(.red.gradient, for: .widget)
    }
}

struct StickIt_Widget: Widget {
    let kind: String = "StickIt_Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            StickIt_WidgetEntryView(entry: entry)
                .modelContainer(for: [Note.self])
        }
        
        .description("Sticky notes for your home screen")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var demo: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.noteId = "noteID"
        return intent
    }
}

#Preview(as: .systemLarge) {
    StickIt_Widget()
} timeline: {
    SimpleEntry(date: .now, configuration: .demo)
}

