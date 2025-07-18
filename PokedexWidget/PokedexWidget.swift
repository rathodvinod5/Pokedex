//
//  PokedexWidget.swift
//  PokedexWidget
//
//  Created by Vinod Rathod on 26/06/25.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Pokemon.self])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create model Container: \(error)")
        }
    }()
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry.placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry.placeholder
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        Task {
            var entries: [SimpleEntry] = []
            
            // Generate a timeline consisting of five entries an hour apart, starting from the current date.
            let currentDate = Date()
            if let results = try? await sharedModelContainer.mainContext
                .fetch(FetchDescriptor<Pokemon>()){
                for hourOffset in 0 ..< 10 {
                    let entryDate = Calendar.current.date(byAdding: .second, value: hourOffset * 5, to: currentDate)!
                    let entryPokemon = results.randomElement()!
                    let entry = SimpleEntry(
                        date: entryDate,
                        name: entryPokemon.name,
                        types: entryPokemon.types,
                        sprite: entryPokemon.spriteImage
                    )
                    entries.append(entry)
                }
                
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            } else {
                let timeline = Timeline(entries: [SimpleEntry.placeholder, SimpleEntry.placeholder2], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let name: String
    let types: [String]
    let sprite: Image
    
    static var placeholder: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "bulbasaur",
            types: ["grass", "poison"],
            sprite: Image(.bulbasaur))
    }
    
    static var placeholder2: SimpleEntry {
        SimpleEntry(
            date: .now,
            name: "mew",
            types: ["psychic"],
            sprite: Image(.mew))
    }
}

struct PokedexWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetSize
    
    var entry: Provider.Entry
    
    var pokemonImage: some View {
        entry.sprite
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .shadow(color: .black, radius: 6)
    }
    
    var typesView: some View {
        ForEach(entry.types, id: \.self) { type in
            Text(type.capitalized)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(.black)
                .padding(.horizontal, 13)
                .padding(.vertical, 5)
                .background(Color(type.capitalized))
                .clipShape(Capsule())
                .shadow(radius: 3)
        }
    }

    var body: some View {
        switch widgetSize {
        case .systemLarge:
            ZStack {
                pokemonImage
                
                VStack(alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.largeTitle)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        typesView
                    }
                }
            }
        case .systemMedium:
            HStack {
                pokemonImage
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text(entry.name.capitalized)
                        .font(.title)
                        .padding(.vertical, 1)
                    
                    HStack {
                        typesView
                    }
                }
                .layoutPriority(1)
                
                Spacer()
            }
        default: pokemonImage
            
        }
    }
}

struct PokedexWidget: Widget {
    let kind: String = "PokedexWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                PokedexWidgetEntryView(entry: entry)
                    .foregroundStyle(.black)
                    .containerBackground(Color(entry.types[0].capitalized), for: .widget)
            } else {
                PokedexWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Pokemon")
        .description("See a random Pokemon")
    }
}

#Preview(as: .systemSmall) {
    PokedexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemMedium) {
    PokedexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}

#Preview(as: .systemLarge) {
    PokedexWidget()
} timeline: {
    SimpleEntry.placeholder
    SimpleEntry.placeholder2
}
