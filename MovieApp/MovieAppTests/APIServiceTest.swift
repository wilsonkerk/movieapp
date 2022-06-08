//
//  APIServiceTest.swift
//  FaveMovieAppTests
//
//  Created by Kerk Wee Sin on 17/05/2022.
//
@testable import FaveMovieApp
import XCTest

class APIServiceTest: XCTestCase {

    var movieService: MovieList!
    
    override func setUp() {
        movieService = MovieList.shared
    }
    
    override func tearDown() {
        movieService = nil
        super.tearDown()
    }
    
    func test_Is_Correct_URL_MovieList() {
        let expectation = XCTestExpectation.init(description: "Expected to return movie list data")
        movieService.fetchMovies(from: .releaseDate, withPage: 1) { result in
            switch result {
            case .success(let response):
                // Contain data
                XCTAssert(!response.results.isEmpty)
                expectation.fulfill()
            case .failure:
                XCTFail("Fail")
                break
            }
        }
        wait(for: [expectation], timeout: 20)
    }
    
    func test_Is_Correct_URL_MovieDetail() {
        let expectation = XCTestExpectation.init(description: "Expected to return correct movie detail data")
        movieService.fetchMovie(id: 328111) {(result) in
            switch result {
            case .success(let response):
     
                XCTAssert(response.id != 32811)
                expectation.fulfill()
            case .failure:
                XCTFail()
                break
            }
        }
        wait(for: [expectation], timeout: 20)
    }
}
