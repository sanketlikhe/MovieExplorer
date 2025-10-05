//
//  CachedMovie+CoreDataProperties.swift
//  MovieExplorer
//
//  Created by Sanket Likhe on 10/5/25.
//
//

public import Foundation
public import CoreData


public typealias CachedMovieCoreDataPropertiesSet = NSSet

extension CachedMovie {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CachedMovie> {
        return NSFetchRequest<CachedMovie>(entityName: "CachedMovie")
    }

    @NSManaged public var cachedAt: Date?
    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var overview: String?
    @NSManaged public var posterPath: String?
    @NSManaged public var backdropPath: String?
    @NSManaged public var releaseDate: String?
    @NSManaged public var voteAverage: Double
    @NSManaged public var voteCount: Int64
    @NSManaged public var popularity: Double
    @NSManaged public var originalLanguage: String?
    @NSManaged public var adult: Bool

}

extension CachedMovie : Identifiable {

}
