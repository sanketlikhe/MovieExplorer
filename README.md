# Movie Explorer iOS App

A modern iOS application that fetches and displays movie data from The Movie Database (TMDb) API with offline support.

## Features

✅ Browse popular movies with infinite scrolling
✅ Search movies by title
✅ View detailed movie information
✅ Offline mode with Core Data caching
✅ Pull-to-refresh functionality
✅ Modern SwiftUI interface
✅ MVVM architecture
✅ Comprehensive unit tests

## Architecture

### MVVM Pattern
- **Models**: `Movie`, `MovieResponse`, `CachedMovie`
- **Views**: `MovieListView`, `MovieDetailView`, `MovieRowView`
- **ViewModels**: `MoviesViewModel`, `MovieDetailViewModel`
- **Repository**: `MovieRepository` (coordinates API and cache)

### Key Design Decisions

1. **Repository Pattern**: Abstracts data sources (API + Cache) behind a single interface, making it easy to switch between online and offline modes.

2. **Protocol-Oriented Design**: All major components (`APIClientProtocol`, `MovieRepositoryProtocol`) use protocols to enable dependency injection and testing.

3. **Async/Await**: Modern Swift concurrency for clean, readable asynchronous code without callback hell.

4. **Core Data for Caching**: Provides robust offline support with relationship management and efficient queries.

5. **Separation of Concerns**: Each layer has a single responsibility, making the code maintainable and testable.

## Setup Instructions

### Prerequisites
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Installation

1. Clone the repository
2. Open `MovieExplorer.xcodeproj` in Xcode
3. Build and run (⌘ + R)

### API Configuration

The app uses TMDb API with the following credentials (already configured):
- API Key: `d04b1d4cc50944705e9d5ee47ef143f1`
- Access Token: Configured in `APIClient.swift`
