//
//  MovieListCollectionViewCell.swift
//  FaveMovieApp
//
//  Created by Kerk Wee Sin on 13/05/2022.
//

import UIKit
import Combine


class MovieListCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var movieImageView: UIImageView!
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    static let cellIdentifier = "MovieListCollectionViewCell"
    private var cancellable: AnyCancellable?
    private var animator: UIViewPropertyAnimator?
    
    override class func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override public func prepareForReuse() {
          super.prepareForReuse()
        movieImageView.image = nil
        movieImageView.alpha = 0.0
        animator?.stopAnimation(true)
        cancellable?.cancel()
      }

      public func configure(with movie: Movie) {
          movieTitleLabel.text = movie.title
          scoreLabel.text = movie.voteAverageScore
          cancellable = loadImage(for: movie).sink { [unowned self] image in self.showImage(image: image) }
      }

      private func showImage(image: UIImage?) {
          movieImageView.alpha = 0.0
          animator?.stopAnimation(false)
          movieImageView.image = image
          animator = UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveLinear, animations: {
              self.movieImageView.alpha = 1.0
          })
      }

      private func loadImage(for movie: Movie) -> AnyPublisher<UIImage?, Never> {
          return Just(movie.posterURL)
          .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
              let url = movie.posterURL
              return ImageLoader.shared.loadImage(from: url)
          })
          .eraseToAnyPublisher()
      }
}
