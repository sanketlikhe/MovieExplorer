//
//  CachedMovie+Extensions.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

internal import CoreData

extension CachedMovie {
    
    /// Convert Core Data entity to Movie model
    func toMovie() -> Movie {
        return Movie(
            id: Int(id),
            title: title!,
            overview: overview,
            posterPath: posterPath,
            backdropPath: backdropPath,
            releaseDate: releaseDate,
            voteAverage: voteAverage == 0 ? nil : voteAverage,
            voteCount: voteCount == 0 ? nil : Int(voteCount),
            popularity: popularity == 0 ? nil : popularity,
            originalLanguage: originalLanguage,
            adult: adult
        )
    }
    
    /// Create or update cached movie from Movie model
    static func createOrUpdate(
        from movie: Movie,
        in context: NSManagedObjectContext
    ) {
        // Check if movie already exists
        let fetchRequest: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", movie.id)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            let cachedMovie: CachedMovie
            
            if let existingMovie = results.first {
                // Update existing movie
                cachedMovie = existingMovie
            } else {
                // Create new movie
                cachedMovie = CachedMovie(context: context)
                cachedMovie.id = Int64(movie.id)
            }
            
            // Update all properties
            cachedMovie.title = movie.title
            cachedMovie.overview = movie.overview
            cachedMovie.posterPath = movie.posterPath
            cachedMovie.backdropPath = movie.backdropPath
            cachedMovie.releaseDate = movie.releaseDate
            cachedMovie.voteAverage = movie.voteAverage ?? 0.0
            cachedMovie.voteCount = Int64(movie.voteCount ?? 0)
            cachedMovie.popularity = movie.popularity ?? 0.0
            cachedMovie.originalLanguage = movie.originalLanguage
            cachedMovie.adult = movie.adult ?? false
            cachedMovie.cachedAt = Date()
            
        } catch {
            print("❌ Failed to create or update cached movie: \(error.localizedDescription)")
        }
    }
    
    /// Delete old cached movies (older than specified days)
    static func deleteOldMovies(
        olderThanDays days: Int,
        in context: NSManagedObjectContext
    ) {
        let fetchRequest: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        
        if let cutoffDate = Calendar.current.date(byAdding: .day, value: -days, to: Date()) {
            fetchRequest.predicate = NSPredicate(format: "cachedAt < %@", cutoffDate as NSDate)
            
            do {
                let oldMovies = try context.fetch(fetchRequest)
                oldMovies.forEach { context.delete($0) }
                
                if context.hasChanges {
                    try context.save()
                    print("✅ Deleted \(oldMovies.count) old cached movies")
                }
            } catch {
                print("❌ Failed to delete old movies: \(error.localizedDescription)")
            }
        }
    }
}
