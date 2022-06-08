//
//  APIService.swift
//  FaveMovieApp
//
//  Created by Kerk Wee Sin on 11/05/2022.
//

import Foundation
import RxSwift

// Protocol
protocol MovieService {

    func fetchMovie(id: Int, completion: @escaping (Result<MovieDetail, APIError>) -> ())
    func fetchMovies(from endpoint: MovieListCategory, withPage: Int, completion: @escaping (Result<APIResponse, APIError>) -> ())
   
}

class MovieList: MovieService {
    static let shared = MovieList()
    private init() {}
    
    private let apiKey = "328c283cd27bd1877d9080ccb1604c91"
    private let baseAPIURL = "https://api.themoviedb.org/3/"
    private let urlSession = URLSession.shared
    private let jsonDecoder = Utils.jsonDecoder
    private let releaseDate = "2016-12-31"
    
    // To fetch selected movie details
    func fetchMovie(id: Int, completion: @escaping (Result<MovieDetail, APIError>) -> ()) {
        guard let url = URL(string: "\(baseAPIURL)movie/\(id)?api_key=\(apiKey)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadURLAndDecode(url: url, params: [
            "append_to_response": "videos,credits"
        ], completion: completion)
    }
    
    //To fetch the list of movies according to page and sorting
    func fetchMovies(from endpoint: MovieListCategory, withPage: Int, completion: @escaping (Result<APIResponse, APIError>) -> ()) {
        guard let url = URL(string: "\(baseAPIURL)discover/movie?api_key=\(apiKey)&primary_release_date.lte=\(releaseDate)&sort_by=\(endpoint.rawValue).desc&page=\(withPage)") else {
            completion(.failure(.invalidEndpoint))
            return
        }
        self.loadURLAndDecode(url: url, completion: completion)
    }
    
    
    private func loadURLAndDecode<D: Decodable>(url: URL, params: [String: String]? = nil, completion: @escaping (Result<D, APIError>) -> ()) {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
//        var queryItems = [URLQueryItem(name: "api_key", value: apiKey)]
//        if let params = params {
//            queryItems.append(contentsOf: params.map { URLQueryItem(name: $0.key, value: $0.value) })
//        }
//
//        urlComponents.queryItems = queryItems
        
        guard let finalURL = urlComponents.url else {
            completion(.failure(.invalidEndpoint))
            return
        }
        
        urlSession.dataTask(with: finalURL) { [weak self] (data, response, error) in
            guard let self = self else { return }
            
            if error != nil {
                self.executeCompletionHandler(with: .failure(.apiError), completion: completion)
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, 200..<300 ~= httpResponse.statusCode else {
                self.executeCompletionHandler(with: .failure(.invalidResponse), completion: completion)
                return
            }
            
            guard let data = data else {
                self.executeCompletionHandler(with: .failure(.noData), completion: completion)
                return
            }
            
            do {
                let decodedResponse = try self.jsonDecoder.decode(D.self, from: data)
                self.executeCompletionHandler(with: .success(decodedResponse), completion: completion)
            } catch {
                self.executeCompletionHandler(with: .failure(.serializationError), completion: completion)
            }
        }.resume()
    }
    
    private func executeCompletionHandler<D: Decodable>(with result: Result<D, APIError>, completion: @escaping (Result<D, APIError>) -> ()) {
        DispatchQueue.main.async {
            completion(result)
        }
        
    }
}

enum MovieListCategory: String, CaseIterable, Identifiable {
    
    var id: String { rawValue }
    
    case releaseDate = "release_date"
    case alphabetical = "alphabetical"
    case rating = "rating"
    
    var description: String {
        switch self {
            case .releaseDate: return "Release Date"
            case .alphabetical: return "Alphabetical"
            case .rating: return "Rating"
        }
    }
    
    static func getEnumValue(withString: String) -> MovieListCategory {
        switch withString {
            case "Release Date" : return .releaseDate
            case "Alphabetical" : return .alphabetical
            case "Rating" : return  .rating
        default:
            return .releaseDate
        }
    }
}

enum APIError: Error, CustomNSError {
    
    case apiError
    case invalidEndpoint
    case invalidResponse
    case noData
    case serializationError
    
    var localizedDescription: String {
        switch self {
        case .apiError: return "Failed to fetch data"
        case .invalidEndpoint: return "Invalid endpoint"
        case .invalidResponse: return "Invalid response"
        case .noData: return "No data"
        case .serializationError: return "Failed to decode data"
        }
    }
    
    var errorUserInfo: [String : Any] {
        [NSLocalizedDescriptionKey: localizedDescription]
    }
    
}


