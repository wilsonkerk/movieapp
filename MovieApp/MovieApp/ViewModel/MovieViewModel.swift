//
//  MovieViewModel.swift
//  FaveMovieApp
//
//  Created by Kerk Wee Sin on 13/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct SectionMovieData {
  var header: String
  var items: [Item]
}
extension SectionMovieData: AnimatableSectionModelType {
  typealias Item = Movie
    typealias Identity = String
    
    var identity: String {
        return header
    }

   init(original: SectionMovieData, items: [Item]) {
    self = original
    self.items = items
  }
}

extension Movie: IdentifiableType {
    typealias Identity = String
    
    var identity: String {
        return id.description
    }
}


class MovieViewModel {

    var movies = BehaviorSubject<[Movie]>(value: [])
    var dataSource = RxCollectionViewSectionedAnimatedDataSource<SectionMovieData>(configureCell: { (_, _, _, _) in
        fatalError()
    })
    
    func fetchMoviesList(from endpoint: MovieListCategory = .releaseDate, page: Int = 1) {
        MovieList.shared.fetchMovies(from: endpoint, withPage: page) { result in
            switch result {
            case .success(let response):
                self.movies.on(.next(response.results))
                
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    func updateMoviesList(from endpoint: MovieListCategory = .releaseDate, page: Int = 1) {
        MovieList.shared.fetchMovies(from: endpoint, withPage: page) { result in
            switch result {
            case .success(let response):
                
                var combinedData = try! self.movies.value()
                combinedData.append(contentsOf: response.results)
                self.movies.on(.next(combinedData.uniqued()))
                
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
    
    func getSelectedMovieId(indexPath:IndexPath) -> Int? {
        guard let sections = try? movies.value() else { return nil}
        let currentSection = sections[indexPath.row]
        return  currentSection.id
    }
}

class MovieDetailViewModel {
    var movieDetail = BehaviorSubject<MovieDetail?>(value: nil)
    func loadMovieDetail(id: Int) {

        MovieList.shared.fetchMovie(id: id) {[weak self] (result) in
            
            switch result {
            case .success(let movie):

                self?.movieDetail.on(.next(movie))
            case .failure(let error):
                print(error.localizedDescription)
                break
            }
        }
    }
}
