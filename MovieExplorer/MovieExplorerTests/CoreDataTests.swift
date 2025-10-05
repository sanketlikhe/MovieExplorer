//
//  CoreDataTests.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//

import XCTest
import CoreData
@testable import MovieExplorer

final class CoreDataTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUp() {
        super.setUp()
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDown() {
        persistenceController = nil
        context = nil
        super.tearDown()
    }
    
    func testCreateCachedMovie() throws {
        // Given
        let movie = CachedMovie(context: context)
        movie.id = 1
        movie.title = "Test Movie"
        movie.overview = "Test overview"
        movie.voteAverage = 7.5
        movie.cachedAt = Date()
        
        // When
        try context.save()
        
        // Then
        let fetchRequest: NSFetchRequest<CachedMovie> = CachedMovie.fetchRequest()
        let results = try context.fetch(fetchRequest)
        
        XCTAssertEqual(results.count, 1)
    }
    
    func testCachedMovieToMovie() {
        // Given
        let cachedMovie = CachedMovie(context: context)
        cachedMovie.id = 11
        cachedMovie.title = "Star Wars"
        cachedMovie.overview = "Epic space opera"
        cachedMovie.posterPath = "/poster.jpg"
        cachedMovie.releaseDate = "1977-05-25"
        cachedMovie.voteAverage = 8.2
        cachedMovie.voteCount = 19521
        cachedMovie.cachedAt = Date()
        
        // When
        let movie = cachedMovie.toMovie()
        
        // Then
        XCTAssertEqual(movie.id, 11)
        XCTAssertEqual(movie.title, "Star Wars")
        XCTAssertEqual(movie.overview, "Epic space opera")
        XCTAssertEqual(movie.voteAverage, 8.2)
    }
    
    
}
