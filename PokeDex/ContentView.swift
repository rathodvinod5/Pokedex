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
    @State private var filterByFavorites: Bool = false
    
    let fetcher = FetchService()
    let pokemonSize = 152
    
    private var dynamicPredecates: NSPredicate {
        var predicates: [NSPredicate] = []
        
        // search predecate
        if !searchText.isEmpty {
            predicates.append(NSPredicate(format: "name contains[c] %@", searchText))
        }
        
        // filter by favourite predicate
        if filterByFavorites {
            predicates.append(NSPredicate(format: "favorite == %d", true))
        }
        
        // combine predicate
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }

    var body: some View {
        if pokedex.isEmpty {
            ContentUnavailableView {
                Label("No Pokemon Found", image: .nopokemon)
            } description: {
                Text("There's no pokemon yet. \nFetch some pokemon to get started")
            } actions: {
                Button("Fetch Pokmon", systemImage: "antena.radiowave.left.and.right") {
                    getPokemon(from: 1)
                }
                .buttonStyle(.borderedProminent)
            }

        } else {
            NavigationStack {
                List {
                    Section {
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
                                    HStack {
                                        Text(pokemon.name!.capitalized)
                                            .fontWeight(.bold)
                                        
                                        if pokemon.favorite {
                                            Image(systemName: "star.fill")
                                                .foregroundStyle(.yellow)
                                        }
                                    }
                                    
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
                    } footer: {
                        if pokedex.count < pokemonSize - 1 {
                            ContentUnavailableView {
                                Label("Missing Pokemon", image: .nopokemon)
                            } description: {
                                Text("The fetch was interrupted!. \nFetch the rest of the Pokemon")
                            } actions: {
                                Button("Fetch Pokmon", systemImage: "antena.radiowave.left.and.right") {
                                    getPokemon(from: pokedex.count + 1)
                                }
                                .buttonStyle(.borderedProminent)
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
                .onChange(of: filterByFavorites) {
                    pokedex.nsPredicate = dynamicPredecates
                }
                .navigationDestination(for: Pokemon.self, destination: { pokemon in
                    Text(pokemon.name ?? "no name")
                })
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            filterByFavorites.toggle()
                        } label: {
                            Label("Filter by favorites", systemImage: filterByFavorites ? "star.fill" : "star")
                        }
                        .tint(.yellow)
                    }
                }
            }
        }
    }

    private func getPokemon(from id: Int) {
        Task {
            for i in id..<pokemonSize {
                do {
                    let fetchedPokemon = try await fetcher.fetchPokemon(i)
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
