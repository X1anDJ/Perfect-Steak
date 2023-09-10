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
            OnboardingSlide(title: "No measurement while baking", description: "No need to open the oven again and again to measure the temperature. Bake time will be calculated before baking. ", image: #imageLiteral(resourceName: "P2")),
            OnboardingSlide(title: "No extra tool needed", description: "Setup parameters without extra tools: Defrost the steak to room temperature, then measure the thickness with built-in ruler. ", image: #imageLiteral(resourceName: "P1"))
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
