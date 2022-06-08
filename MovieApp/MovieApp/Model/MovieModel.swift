//
//  Movie.swift
//  FaveMovieApp
//
//  Created by Kerk Wee Sin on 11/05/2022.
//

import Foundation

struct APIResponse: Decodable {
    let results: [Movie]
}

struct Movie: Decodable, Identifiable, Hashable, Equatable {
    static func == (lhs: Movie, rhs: Movie) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let adult: Bool
    let backdropPath: String?
    let genreIds: [Int]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate: String
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    
    var voteAverageScore: String {
        return voteAverage > 0 ? voteAverage.description : "n/a"
    }
    
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")!
    }
    
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
}

struct MovieDetail: Decodable, Identifiable, Hashable {
    static func == (lhs: MovieDetail, rhs: MovieDetail) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    let adult: Bool
    let backdropPath: String?
    let genres: [Genres]
    let id: Int
    let originalLanguage: String
    let originalTitle: String
    let overview: String
    let popularity: Double
    let posterPath: String?
    let releaseDate: String
    let title: String
    let video: Bool
    let voteAverage: Double
    let voteCount: Int
    let runtime: Int
    let spokenLanguages: [Language]
    
    struct Genres: Decodable {
        let id: Int
        let name: String
    }
    
    struct Language: Decodable {
        let englishName: String
        let iso6391: String
        let name: String
    }
    
    var backdropURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(backdropPath ?? "")")!
    }
    
    var posterURL: URL {
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath ?? "")")!
    }
    
    var overviewString: String {
        return overview.isEmpty ? "n/a" : overview
    }
    
    var genresList: String? {
        guard !genres.isEmpty else {return ""}
        
        let genresList = genres.map({$0.name})
        var genresCombineText = ""
        genresList.forEach { (genre) in
            genresCombineText.append(contentsOf: genresList.last == genre ? genre : genre + ", ")
        }
        
        return genresCombineText.isEmpty ? "" : genresCombineText
    }
    
    var durationAndLanguage: String? {
        var string = ""
        if let lang = spokenLanguages.first?.name {
            string.append(contentsOf: lang)
        }
        if runtime > 0 {
            let duration = Utils.minutesToHoursAndMinutes(runtime)
            string.append(contentsOf: string.isEmpty ? "\(duration.hours) hours and \(duration.leftMinutes) minutes" : ", \(duration.hours) hours and \(duration.leftMinutes) minutes")
        }

        return string.isEmpty ? "n/a" : string
    }
}


