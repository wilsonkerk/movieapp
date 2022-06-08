//
//  ViewController.swift
//  FaveMovieApp
//
//  Created by Kerk Wee Sin on 11/05/2022.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import UIScrollView_InfiniteScroll

class MovieListViewController: UIViewController, UICollectionViewDelegate, dropDownProtocol {

    @IBOutlet weak var collectionView: UICollectionView!
    let disposeBag = DisposeBag()

    private var viewModel = MovieViewModel()
    var dropdownButton = dropDownBtn()
    var selectedMovieCategory: MovieListCategory = .releaseDate
    var page = 1
    var refreshControl: UIRefreshControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // iOS new magazine navigation title effect setup
        self.title = "Recent Movies"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        bidingCollectionView()
        loadData()
        setupDropdown()
        setupCollectionView()
       
        
    }
    
    private func setupCollectionView() {
        // add in refreshControl to refresh data when pull down the view.
        refreshControl = UIRefreshControl()
        collectionView.addSubview(refreshControl!)
        // observe the refreshControl and start fetch data
        refreshControl?.rx.controlEvent(.primaryActionTriggered).asObservable()
            .subscribe(onNext: { [unowned self] in
                self.viewModel.fetchMoviesList(from: self.selectedMovieCategory)
                self.refreshControl?.endRefreshing()
            })
            .disposed(by: disposeBag)
        
        // add inifinite scroll into collectionView for lazy load pagination
        collectionView.addInfiniteScroll { collectionView in
        }
    }
    
    // setup dropdown for movie category selection filter
    private func setupDropdown() {
        //Configure the button
        dropdownButton = dropDownBtn.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        dropdownButton.setTitle("Sort by: Release date", for: .normal)
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        
        //Add Button to the View Controller
        self.view.addSubview(dropdownButton)
        
        //button Constraints
        dropdownButton.topAnchor.constraint(equalTo: self.collectionView.topAnchor, constant: -50).isActive = true
        dropdownButton.rightAnchor.constraint(equalTo: self.collectionView.rightAnchor).isActive = true
        dropdownButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        dropdownButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        //Set the drop down menu's options
        dropdownButton.dropView.dropDownOptions = MovieListCategory.allCases.map({$0.description})
        dropdownButton.dropView.delegate = self
    }
    
    // RXSwift data binding after data successfully return from API
    private func bidingCollectionView() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        
        viewModel.dataSource.configureCell = { datasource, collectionView, indexPath, movie in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MovieListCollectionViewCell.cellIdentifier, for: indexPath) as! MovieListCollectionViewCell
            cell.configure(with: movie)
            return cell
        }
       
        let movieDataSource = viewModel.dataSource
        viewModel.movies.asObservable()
            // Map all the movie list under "Movies" header, can map under other header if any
            .map({[SectionMovieData.init(header: "Movies", items: $0)]})
            .bind(to: collectionView.rx.items(dataSource: movieDataSource))
            .disposed(by: disposeBag)
        
        // Manage after collectionView cell been selected
        collectionView.rx.itemSelected.subscribe(onNext: { indexPath in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: String(describing: MovieDetailViewController.self)) as! MovieDetailViewController
            vc.movieId = self.viewModel.getSelectedMovieId(indexPath: indexPath)
            DispatchQueue.main.async {
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    @objc private func loadData() {
        viewModel.fetchMoviesList()
    }
    
    func dropDownPressed(string: String) {
        let movieCategory = MovieListCategory.getEnumValue(withString: string)
        selectedMovieCategory = movieCategory
        viewModel.fetchMoviesList(from: movieCategory)
    }
    
    // Fetch for next page movie list
    private func performFetch(_ completionHandler: (() -> Void)?) {
        self.page = self.page + 1
        viewModel.updateMoviesList(from: selectedMovieCategory, page: page)
    }
    
    // To check scrolling is current end of the movie list to prepare fetch next page of movie list
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        print(scrollView.contentOffset)
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        
        // Change 10.0 to adjust the distance from bottom
        if maximumOffset - currentOffset <= 10.0 {
            print("should load more")
            self.performFetch({
                self.collectionView.finishInfiniteScroll()
            })
        }
    }
}
