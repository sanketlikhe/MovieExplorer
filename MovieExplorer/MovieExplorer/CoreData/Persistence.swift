//
//  Persistence.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

internal import CoreData

final class PersistenceController {
    
    // MARK: - Singleton
    
    /// Shared instance for production use
    static let shared = PersistenceController()
    
    /// Preview instance with in-memory store for SwiftUI previews
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        
        // Create sample data for previews
        for i in 0..<10 {
            let movie = CachedMovie(context: viewContext)
            movie.id = Int64(i + 1)
            movie.title = "Sample Movie \(i + 1)"
            movie.overview = "This is a sample movie overview for movie number \(i + 1). It's a great film with amazing actors and stunning visuals."
            movie.releaseDate = "2024-0\(i + 1)-15"
            movie.voteAverage = Double.random(in: 6.0...9.0)
            movie.voteCount = Int64.random(in: 100...5000)
            movie.posterPath = "/sample\(i).jpg"
            movie.backdropPath = "/backdrop\(i).jpg"
            movie.popularity = Double.random(in: 50...500)
            movie.originalLanguage = "en"
            movie.adult = false
            movie.cachedAt = Date()
        }
        
        do {
            try viewContext.save()
            print("✅ Preview data created successfully")
        } catch {
            print("❌ Preview setup failed: \(error)")
        }
        
        return controller
    }()
    
    // MARK: - Container
    
    let container: NSPersistentContainer
    
    // MARK: - Computed Properties
    
    /// Main view context for UI operations
    var viewContext: NSManagedObjectContext {
        container.viewContext
    }
    
    // MARK: - Initialization
    
    /// Initialize Core Data stack
    /// - Parameter inMemory: If true, uses in-memory store (for testing/previews)
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MovieExplorer")
        
        if inMemory {
            // Use in-memory store for testing
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // Configure persistent store
            if let storeDescription = container.persistentStoreDescriptions.first {
                // Enable persistent history tracking
                storeDescription.setOption(true as NSNumber,
                                          forKey: NSPersistentHistoryTrackingKey)
                storeDescription.setOption(true as NSNumber,
                                          forKey: NSPersistentStoreRemoteChangeNotificationPostOptionKey)
            }
        }
        
        // Load persistent stores
        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible due to permissions or data protection.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 */
                fatalError("❌ Unresolved Core Data error \(error), \(error.userInfo)")
            } else {
                print("✅ Core Data stack initialized: \(storeDescription.url?.lastPathComponent ?? "unknown")")
            }
        }
        
        // Configure view context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        
        // Set reasonable batch size for fetching
        container.viewContext.undoManager = nil
        container.viewContext.shouldDeleteInaccessibleFaults = true
    }
    
    // MARK: - Public Methods
    
    /// Save the view context if there are changes
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else {
            print("ℹ️ No changes to save")
            return
        }
        
        do {
            try context.save()
            print("✅ Context saved successfully")
        } catch {
            let nsError = error as NSError
            print("❌ Failed to save context: \(nsError), \(nsError.userInfo)")
            
            // In production, handle error appropriately
            // For now, we'll just log it
        }
    }
    
    /// Create a new background context for heavy operations
    func newBackgroundContext() -> NSManagedObjectContext {
        let context = container.newBackgroundContext()
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return context
    }
    
    /// Perform operation in background context
    func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            block(context)
        }
    }
    
    /// Delete all cached movies
    func deleteAllMovies() {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CachedMovie.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchDeleteRequest.resultType = .resultTypeObjectIDs
        
        do {
            let result = try viewContext.execute(batchDeleteRequest) as? NSBatchDeleteResult
            
            if let objectIDs = result?.result as? [NSManagedObjectID] {
                let changes = [NSDeletedObjectsKey: objectIDs]
                NSManagedObjectContext.mergeChanges(
                    fromRemoteContextSave: changes,
                    into: [viewContext]
                )
                print("✅ Deleted all cached movies: \(objectIDs.count) items")
            }
        } catch {
            print("❌ Failed to delete all movies: \(error)")
        }
    }
    
    /// Get count of cached movies
    func getCachedMoviesCount() -> Int {
        let fetchRequest: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        do {
            return try viewContext.count(for: fetchRequest)
        } catch {
            print("❌ Failed to get movies count: \(error)")
            return 0
        }
    }
}
