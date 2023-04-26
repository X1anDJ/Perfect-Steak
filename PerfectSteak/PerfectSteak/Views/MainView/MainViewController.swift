//
//  MainViewController.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/25/23.
//

import UIKit

class MainViewController: UIViewController {
    private var recipes = Recipes()
    private var selectedRecipe: SteakRecipe!
    private var recipeDropdownMenu: RecipeDropdownTableViewController?
    private var popoverController: UIPopoverPresentationController?
    
    @IBOutlet weak var titleButton: UIButton!
    
    @IBOutlet weak var circularSliderTest: CircularSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupNavigationBar()
        
        createSampleRecipes()
        
        setupSelectedRecipe()
        
        // Do any additional setup after loading the view.
    }
    
    private func setupNavigationBar() {
        titleButton.addTarget(self, action: #selector(showRecipeDropdownMenu), for: .touchUpInside)
    }
    
    private func setupSelectedRecipe() {
        let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        selectedRecipe = recipes.fetchRecipe(with: defaultUUID)!
        updateTitle()
    }
    

    private func updateTitle() {
        let button = navigationItem.titleView as? UIButton
        button?.setTitle(selectedRecipe.title, for: .normal)
    }

   
    @objc private func showRecipeDropdownMenu() {
            let menu = RecipeDropdownTableViewController()
            menu.modalPresentationStyle = .popover
            menu.preferredContentSize = CGSize(width: 200, height: 200)
            menu.recipesManager = recipes
            menu.recipes = recipes.steakRecipes
            menu.didSelectRecipe = { [weak self] recipe in
                self?.selectedRecipe = recipe
                self?.updateTitle()
            }
        
            
            
            popoverController = menu.popoverPresentationController
            popoverController?.delegate = self
            popoverController?.sourceView = navigationItem.titleView
            popoverController?.sourceRect = navigationItem.titleView?.bounds ?? .zero
            popoverController?.permittedArrowDirections = .any

            present(menu, animated: true, completion: nil)
    }
    
    func createSampleRecipes() {
        let userDefaults = UserDefaults.standard
        let sampleRecipesCreatedKey = "sampleRecipesCreated"

        if !userDefaults.bool(forKey: sampleRecipesCreatedKey) {
            let sampleRecipe1 = SteakRecipe(thickness: 3, initialTemp: 25, ovenTemp: 190, desiredCenterTemp: 65)
            let sampleRecipe2 = SteakRecipe(thickness: 2, initialTemp: 30, ovenTemp: 180, desiredCenterTemp: 70)

            recipes.addSteakRecipe(sampleRecipe1)
            recipes.addSteakRecipe(sampleRecipe2)

            // Set the flag in UserDefaults
            userDefaults.set(true, forKey: sampleRecipesCreatedKey)
        }
    }
    

}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
