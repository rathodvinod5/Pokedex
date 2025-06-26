//
//  PokedexWidget.swift
//  PokedexWidget
//
//  Created by Vinod Rathod on 26/06/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry.placeholder
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry.placeholder
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let type: [String]
    let sprite: Image
    
    static var placeholder: SimpleEntry {
        SimpleEntry(
            date: .now,
            emoji: "bulbasaur",
            type: ["grass", "poison"],
            sprite: Image(.bulbasaur))
    }
    
    static var placeholder2: SimpleEntry {
        SimpleEntry(
            date: .now,
            emoji: "mew",
            type: ["psychic"],
            sprite: Image(.mew))
    }
}

struct PokedexWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            entry.sprite
        }
    }
}

struct PokedexWidget: Widget {
    let kind: String = "PokedexWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PokedexWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                PokedexWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    PokedexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}
