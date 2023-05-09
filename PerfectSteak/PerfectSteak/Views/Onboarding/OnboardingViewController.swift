//
//  OnboardingViewController.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/24/23.
//

import UIKit


import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    
    var slides: [OnboardingSlide] = []
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            if currentPage == slides.count - 1 {
                nextButton.setTitle("Get Started!", for: .normal)
            } else {
                nextButton.setTitle("Next", for: .normal)
            }
        }
    }
    
    func setOnboardingStatus() {
        UserDefaults.standard.set(true, forKey: "hasSeenOnboarding")
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        slides = [
            OnboardingSlide(title: "Cook Like a Physicist", description: "Calculate steak's temperature by solving the 1D heat equation with the Crank-Nicolson method in just a few steps.", image: #imageLiteral(resourceName: "1d")),
            OnboardingSlide(title: "1. Select doneness", description: "Slide up and down to pick your favourite doneness", image: #imageLiteral(resourceName: "Image")),
            OnboardingSlide(title: "2. Pick the right temperature", description: "Slide up and down to pick the stove temperature and ", image: #imageLiteral(resourceName: "c"))
        ]
        
        pageControl.numberOfPages = slides.count
        
    }
    
    @IBAction func nextButtonClicked(_ sender: UIButton) {
        if currentPage == slides.count - 1 {
            setOnboardingStatus()
            let controller = storyboard?.instantiateViewController(withIdentifier: "HomeNC") as! UINavigationController
            controller.modalPresentationStyle = .fullScreen
            controller.modalTransitionStyle = .crossDissolve
            present(controller, animated: true)  //!111
        } else {
            currentPage += 1
            let indexPath =  IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        
    }
    
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //number of item in section depends on number of slides
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    //
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        cell.setup(slides[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
        pageControl.currentPage = currentPage
    }
}
