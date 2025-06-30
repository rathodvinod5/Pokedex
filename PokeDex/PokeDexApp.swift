//
//  PokeDexApp.swift
//  PokeDex
//
//  Created by Vinod Rathod on 09/06/25.
//

import SwiftUI
import SwiftData

@main
struct PokeDexApp: App {
    let sharedModelContainer: ModelContainer = {
        let schema = Schema([Pokemon.self])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create model Container: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(sharedModelContainer)
        }
    }
}
