//
//  ContentView.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import SwiftUI

/// Alternative content view if you want a tab-based navigation
struct ContentView: View {
    var body: some View {
        TabView {
            MovieListView()
                .tabItem {
                    Label("Movies", systemImage: "film")
                }
            
            CacheInfoView()
                .tabItem {
                    Label("Cache", systemImage: "internaldrive")
                }
        }
    }
}

/// Debug view to show cache information
struct CacheInfoView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State private var cachedCount: Int = 0
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            List {
                Section("Cache Statistics") {
                    HStack {
                        Text("Cached Movies")
                        Spacer()
                        Text("\(cachedCount)")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Storage Type")
                        Spacer()
                        Text("Core Data")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive, action: {
                        showingClearAlert = true
                    }) {
                        HStack {
                            Spacer()
                            Text("Clear All Cache")
                            Spacer()
                        }
                    }
                }
                
                Section("About") {
                    Text("Cached movies are stored locally using Core Data for offline access. The app automatically updates the cache when fetching new data from the API.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Cache Info")
            .onAppear {
                updateCacheCount()
            }
            .alert("Clear Cache", isPresented: $showingClearAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Clear", role: .destructive) {
                    clearCache()
                }
            } message: {
                Text("Are you sure you want to clear all cached movies? This cannot be undone.")
            }
        }
    }
    
    private func updateCacheCount() {
        cachedCount = PersistenceController.shared.getCachedMoviesCount()
    }
    
    private func clearCache() {
        PersistenceController.shared.deleteAllMovies()
        updateCacheCount()
    }
}

#Preview("Cache Info") {
    CacheInfoView()
        .environment(\.managedObjectContext, PersistenceController.preview.viewContext)
}
