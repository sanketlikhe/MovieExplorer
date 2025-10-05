//
//  MovieExplorerApp.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import SwiftUI
internal import CoreData

@main
struct MovieExplorerApp: App {
    
    // Initialize Core Data persistence controller
    let persistenceController = PersistenceController.shared
    
    init() {
        // Configure app appearance
        setupAppearance()
        
        // Clean up old cached movies (optional - older than 30 days)
        cleanupOldCache()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
    
    // MARK: - Private Methods
    
    private func setupAppearance() {
        // Customize navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
    
    private func cleanupOldCache() {
        Task {
            let context = persistenceController.container.newBackgroundContext()
            await context.perform {
                CachedMovie.deleteOldMovies(olderThanDays: 30, in: context)
            }
        }
    }
}
