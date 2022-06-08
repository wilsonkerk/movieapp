//
//  MovieDetailViewController.swift
//  FaveMovieApp
//
//  Created by Kerk Wee Sin on 14/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import WebKit

class MovieDetailViewController: UIViewController {
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var movieDescLabel: UILabel!
    @IBOutlet weak var durationAndLanguageLabel: UILabel!
    
    private var viewModel = MovieDetailViewModel()
    var movieId: Int! // MovieId must not nil to fetch selected movie detail.
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Book", style: .done, target: self, action: #selector(bookTapped))
        
        viewModel.loadMovieDetail(id: movieId)
        bindingData()
    }
    
    // To load booking website
    @objc func bookTapped() {
        let webview = WebviewVC()
        self.present(webview, animated: true)
    }
    
    // Binding movie detail data
    private func bindingData() {
        //let movieDetail = try? viewModel.movieDetail.value()
        viewModel.movieDetail.bind { movieDetail in
            self.movieTitleLabel.text = movieDetail?.title
            if let url = movieDetail?.posterURL {
                self.movieImageView.downloaded(from: url)
            }
            self.overviewLabel.text = movieDetail?.overviewString
            self.movieDescLabel.text = movieDetail?.genresList
            self.durationAndLanguageLabel.text = movieDetail?.durationAndLanguage
        }
        .disposed(by: disposeBag)
  
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
