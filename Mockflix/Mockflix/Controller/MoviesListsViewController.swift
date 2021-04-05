//
//  MoviesListsViewController.swift
//  Mockflix
//
//  Created by Lucas Werner Kuipers on 27/03/2021.
//
// MARK: - Importing required modules

import UIKit
import Alamofire
import AlamofireImage

// MARK: - Entrance point to main class

class MoviesListsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	// MARK: - IBOutlets
	
	@IBOutlet weak var trendingMoviesCollectionView: UICollectionView!
	@IBOutlet weak var popularMoviesCollectionView: UICollectionView!
	@IBOutlet weak var latestMoviesCollectionView: UICollectionView!
	
	
	// MARK: - Global variables and constants
	
	var firstLoad = true // So that position of cells are centered only when app is first opened (not when returning from other view)
	var selectedMovieID: Int? // Index (property of movie's request's response) of clicked movie's poster (to be sent to next view)
	let reallyBigInteger = 10000 // used to create lots of cells and pretend scroll is infinite
	
	// Initializing empty lists of movies that will store movies returned by request
	var trendingMoviesViewModels = [MovieViewModel]()
	var popularMoviesViewModels = [MovieViewModel]()
	var topRatedMoviesViewModels = [MovieViewModel]()
	
	var movieRequester = MoviesRequester() // Object with methods to request movies from API
	
	// MARK: - Life Cycle Methods
	
	// Loaded view
	override func viewDidLoad() {
		super.viewDidLoad()
		
		fetchData()
		
	}
	
	fileprivate func fetchData() {
		self.trendingMoviesViewModels = movieRequester.request(forCategory: "trending/movie/day").map({return MovieViewModel(movie: $0)})
		self.popularMoviesViewModels = movieRequester.request(forCategory: "movie/popular").map({return MovieViewModel(movie: $0)})
		self.topRatedMoviesViewModels = movieRequester.request(forCategory: "movie/top_rated").map({return MovieViewModel(movie: $0)})
	}
	
	fileprivate func centerScroll() {
		let midIndexPath = IndexPath(row: reallyBigInteger/2 + 1, section: 0) // scrolling to first movie (but at a big index halfway)
		if firstLoad { //Only centering collection when first entering the view (on app's launch)
			trendingMoviesCollectionView.scrollToItem(at: midIndexPath, at: .centeredHorizontally, animated: false)
			popularMoviesCollectionView.scrollToItem(at: midIndexPath, at: .centeredHorizontally, animated: false)
			latestMoviesCollectionView.scrollToItem(at: midIndexPath, at: .centeredHorizontally, animated: false)
			firstLoad = false
		}
	}
	
	// Seeing view
	override func viewDidAppear(_ animated: Bool) {
		// Centering collection to cell at mid index (illusion of infinite scroll)
		centerScroll()
	}
	
	// Leaving view
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		// Passing this view controller as a variable to the next screen (in order to access selected movie index
		if let viewController = segue.destination as? MovieDetailsViewController {
			viewController.movieListViewController = self
		}
	}
	
	// MARK: - Collection View Methods
	
	// Determining how many cells should be displayed in collection view
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return reallyBigInteger // used to create illusion of infinite scroll
	}
	
	// Setting up each cell to be displayed
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		
		// Creating general cell object inside collection view
		if collectionView == trendingMoviesCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCellTrending", for: indexPath) as! MovieCollectionViewCellTrending
			
			// In case no single movie is returned, preventing division by 0 on index access
			if trendingMoviesViewModels.count <= 0 { return cell }
			
			// Storing corresponding movie in a local variable
			let movie = trendingMoviesViewModels[indexPath.row % trendingMoviesViewModels.count]
			
			// MARK: - Filling cell with corresponding movie's poster image
			// Getting image's info
			let posterImageBaseURL = "https://image.tmdb.org/t/p/w300/"
			guard let posterImageParameters = movie.posterPath else { return cell}
			let posterImageFullURLString = "\(posterImageBaseURL)\(posterImageParameters)"
			let posterImageURL = URL(string: posterImageFullURLString)
			// Setting image on cell
			cell.moviePosterImageTrending.af_setImage(withURL: posterImageURL!)
			cell.moviePosterImageTrending.layer.cornerRadius = 20
			cell.moviePosterImageTrending.clipsToBounds = true
			
			return cell
		} else if collectionView == popularMoviesCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCellPopular", for: indexPath) as! MovieCollectionViewCellPopular
			
			// In case no single movie is returned, preventing division by 0 on index access
			if popularMoviesViewModels.count <= 0 { return cell }
			
			// Storing corresponding movie in a local variable
			let movie = popularMoviesViewModels[indexPath.row % popularMoviesViewModels.count]
			
			// MARK: - Filling cell with corresponding movie's poster image
			// Getting image's info
			let posterImageBaseURL = "https://image.tmdb.org/t/p/w300/"
			guard let posterImageParameters = movie.posterPath else { return cell}
			let posterImageFullURLString = "\(posterImageBaseURL)\(posterImageParameters)"
			let posterImageURL = URL(string: posterImageFullURLString)
			// Setting image on cell
			cell.moviePosterImagePopular.af_setImage(withURL: posterImageURL!)
			cell.moviePosterImagePopular.layer.cornerRadius = 20
			cell.moviePosterImagePopular.clipsToBounds = true
			
			 return cell
		} else if collectionView == latestMoviesCollectionView {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCellLatest", for: indexPath) as! MovieCollectionViewCellLatest
			
			// In case no single movie is returned, preventing division by 0 on index access
			if topRatedMoviesViewModels.count <= 0 { return cell }
			
			// Storing corresponding movie in a local variable
			let movie = topRatedMoviesViewModels[indexPath.row % topRatedMoviesViewModels.count]
			
			// MARK: - Filling cell with corresponding movie's poster image
			// Getting image's info
			let posterImageBaseURL = "https://image.tmdb.org/t/p/w300/"
			guard let posterImageParameters = movie.posterPath else {return cell}
			let posterImageFullURLString = "\(posterImageBaseURL)\(posterImageParameters)"
			let posterImageURL = URL(string: posterImageFullURLString)
			// Setting image on cell
			cell.moviePosterImageLatest.af_setImage(withURL: posterImageURL!)
			cell.moviePosterImageLatest.layer.cornerRadius = 20
			cell.moviePosterImageLatest.clipsToBounds = true
			
			return cell
		}
		
		else {
			let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MoviePosterCellLatest", for: indexPath) as! MovieCollectionViewCellLatest
			return cell
		}
	
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		if collectionView == trendingMoviesCollectionView {
			selectedMovieID = trendingMoviesViewModels[indexPath.row % trendingMoviesViewModels.count].id
		} else if collectionView == popularMoviesCollectionView {
			selectedMovieID = popularMoviesViewModels[indexPath.row % popularMoviesViewModels.count].id
		} else if collectionView == latestMoviesCollectionView {
			selectedMovieID = topRatedMoviesViewModels[indexPath.row % topRatedMoviesViewModels.count].id

		}
	}
}

