//
//  StickIt_Widget.swift
//  StickIt-Widget
//
//  Created by Alexander Rivera on 4/14/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct NoteProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), config: .demo)
    }

    func snapshot(for configuration: SelectedNote, in context: Context) async -> SimpleEntry {
        await entry(for: configuration)
    }
    
    func timeline(for configuration: SelectedNote, in context: Context) async -> Timeline<SimpleEntry> {
        let entry =  await entry(for: configuration)
        let timeline = Timeline(entries: [entry], policy: .never)
        return timeline
    }
    
    private func entry(for configuration: SelectedNote) async -> SimpleEntry {
        do {
            let modelContext = try ModelContext(.init(for: Note.self))
            
            guard configuration.noteItem != nil else {
                return SimpleEntry(date: Date(), config: .demo)
            }
            
            let id = configuration.noteItem!.id

            let descriptor = FetchDescriptor<Note>(
                predicate: #Predicate { $0.id == id },
                sortBy: []
            )
            
            if (try modelContext.fetch(descriptor).first) != nil {
                return SimpleEntry(date: Date(), config: configuration)
            } else {
                return SimpleEntry(date: Date(), config: .demo)
            }
        } catch {
            return SimpleEntry(date: Date(), config: .demo)
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let config: SelectedNote
}

struct PlaceholderView: View {
    var body: some View {
        Text("Placeholder")
    }
}

struct StickIt_WidgetEntryView: View {
    var entry: NoteProvider.Entry

    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading) {
                headerView()

                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(name: entry.config.noteItem!.color))

                    Markdown(markdownText: .constant("\(String(describing: entry.config.noteItem!.content))"), limit: false)
                        .padding()
                }
                
                .frame(maxWidth: .infinity)
                .frame(height: geo.size.height - 50, alignment: .top)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        
        .foregroundStyle(.white)
        .containerBackground(Color(name: entry.config.noteItem!.color).opacity(0.8), for: .widget)
        .widgetURL(URL(string: "stickit//\(entry.config.noteItem!.id)"))
    }
    
    @ViewBuilder
    func headerView() -> some View {
        Text("\(entry.config.noteItem!.name)")
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
            intent: SelectedNote.self,
            provider: NoteProvider()
        ) { entry in
            StickIt_WidgetEntryView(entry: entry)
                .modelContainer(for: [Note.self])
        }
        
        .configurationDisplayName("Sticky Note")
        .description("Sticky notes for your home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

extension SelectedNote {
    fileprivate static var demo: SelectedNote {
        let intent = SelectedNote()
        intent.noteItem = .placeholder
        return intent
    }
}

#Preview(as: .systemExtraLarge) {
    StickIt_Widget()
} timeline: {
    SimpleEntry(date: Date(), config: .demo)
}

