//
//  ContentView.swift
//  PokeDex
//
//  Created by Vinod Rathod on 09/06/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest<Pokemon>(
        sortDescriptors: [SortDescriptor(\.id)],
        animation: .default
    )private var pokedex
    
    @State private var searchText: String = ""
    
    let fetcher = FetchService()
    
    private var dynamicPredecates: NSPredicate {
        var predicates: [NSPredicate] = []
        
        // search predecate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        
        // filter by favourite predicate
        
        // combine predicate
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(pokedex) { pokemon in
                    NavigationLink(value: pokemon) {
                        AsyncImage(url: pokemon.sprite) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 100, height: 100)
                        
                        VStack(alignment: .leading) {
                            Text(pokemon.name!.capitalized)
                                .fontWeight(.bold)
                            
                            HStack {
                                if let types = pokemon.types {
                                    ForEach(types, id: \.self) { type in
                                        let capitalizedType = type.capitalized
                                        Text(capitalizedType)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundStyle(.black)
                                            .padding(.horizontal, 13)
                                            .padding(.vertical, 5)
                                            .background(Color(capitalizedType))
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Pokedex")
            .searchable(text: $searchText, prompt: "Search Pokemon")
            .autocorrectionDisabled()
            .onChange(of: searchText) {
                pokedex.nsPredicate = dynamicPredecates
            }
            .navigationDestination(for: Pokemon.self, destination: { pokemon in
                Text(pokemon.name ?? "no name")
            })
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button("Add Item", systemImage: "plus") {
                        getPokemon()
                    }
                }
            }
        }
    }

    private func getPokemon() {
        Task {
            for id in 1..<152 {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(id)
                    let pokemon = Pokemon(context: viewContext)
                    pokemon.id = fetchedPokemon.id
                    pokemon.name = fetchedPokemon.name
                    pokemon.types = fetchedPokemon.types
                    pokemon.hp = fetchedPokemon.hp
                    pokemon.attack = fetchedPokemon.attack
                    pokemon.defense = fetchedPokemon.defense
                    pokemon.specialAttack = fetchedPokemon.specialAttack
                    pokemon.specialDefence = fetchedPokemon.specialDefense
                    pokemon.speed = fetchedPokemon.speed
                    pokemon.sprite = fetchedPokemon.sprite
                    pokemon.shiny = fetchedPokemon.shiny
                    
                    try viewContext.save()
                } catch {
                    print(error)
                }
            }
        }
    }
}

#Preview {
    ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
