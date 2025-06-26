//
//  PokemonDetail.swift
//  PokeDex
//
//  Created by Vinod Rathod on 25/06/25.
//

import SwiftUI

struct PokemonDetail: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var pokemon: Pokemon
    
    @State private var showShiny: Bool = false
    
    var body: some View {
        ScrollView {
            ZStack {
                Image(pokemon.background)
                    .resizable()
                    .scaledToFit()
                    .shadow(color: .black, radius: 6)
                
                if pokemon.sprite == nil || pokemon.shiny == nil {
                    AsyncImage(url: showShiny ? pokemon.shinyURL : pokemon.spriteURL) { image in
                        image
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .padding(.top, 50)
                            .shadow(color: .black, radius: 6)
                    } placeholder: {
                        ProgressView()
                    }
                } else {
                    (showShiny ? pokemon.shinyImage : pokemon.spriteImage)
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .padding(.top, 50)
                        .shadow(color: .black, radius: 6)
                }
            }
            
            if let types = pokemon.types {
                HStack {
                    ForEach(types, id: \.self) { type in
                        let capitalizedType = type.capitalized
                        Text(capitalizedType)
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundStyle(.black)
                            .shadow(color: .white, radius: 1)
                            .padding(.vertical, 7)
                            .padding(.horizontal)
                            .background(Color(type.capitalized))
                            .clipShape(Capsule())
                    }
                    
                    Spacer()
                    
                    Button {
                        pokemon.favorite.toggle()
                        
                        do {
                            try viewContext.save()
                        } catch {
                            print(error)
                        }
                    } label: {
                        Image(systemName: pokemon.favorite ? "star.fill" : "star")
                            .font(.largeTitle)
                            .tint(.yellow)
                    }
                }
                .padding()
            }
            
            Text("Stats")
                .font(.title)
                .padding(.bottom, -3)
            
            Stats(pokemon: pokemon)
        }
        .navigationTitle(pokemon.name!.capitalized)
        .toolbar {
            ToolbarItem {
                Button {
                    showShiny.toggle()
                } label: {
                    Image(systemName: showShiny ? "wand.and.stars" : "wand.and.stars.invert")
                        .foregroundStyle(showShiny ? .yellow : .primary)
                }

            }
        }
    }
}

#Preview {
    NavigationStack {
        PokemonDetail()
            .environmentObject(PersistenceController.previewPokemon)
    }
}
