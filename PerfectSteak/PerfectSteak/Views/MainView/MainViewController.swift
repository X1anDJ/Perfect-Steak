//
//  MainViewController.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/25/23.
//


import UIKit
import CoreData

class MainViewController: UIViewController {
    private var recipes = Recipes()
    private var selectedRecipe: SteakRecipe!
    private var currentRecipe: SteakRecipe!
    
    private var recipeDropdownMenu: RecipeDropdownTableViewController?
    private var popoverController: UIPopoverPresentationController?
    
    @IBOutlet weak var titleButton: UIButton!
    
    //Stove temperature button
    @IBOutlet weak var circularSliderTest: CircularSlider!
    
    //Steak Thickness button & label
    @IBOutlet weak var thicknessButton: UIButton!
    @IBOutlet weak var lengthLabel: UILabel!
    
    
    //Doneness button
    @IBOutlet weak var donenessSlider: DonenessSlider!
    
    //Steak temperature button
    @IBOutlet weak var steakTemperature: SteakTemperature!
    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        setupNavigationBar()
        
        createSampleRecipes()
        
        setupSelectedRecipe()
        
        
        
        /*
        print("doneness: \(String(describing: donenessSlider.steakDonenessTitle.text))")
        print("stove temperature: \(String(describing: circularSliderTest.parameterNumber.text))")
        */
        // Do any additional setup after loading the view.
    }
    
    private func updateButtons() {
        // Implemented currenValue as get set, so angle rotation titles will also be changed
        circularSliderTest.currentValue = selectedRecipe.ovenTemp
        steakTemperature.currentValue = selectedRecipe.initialTemp
        lengthLabel.text = String(selectedRecipe.thickness)
        donenessSlider.currentDoneness = SteakDoneness.fromTemperature(selectedRecipe.desiredCenterTemp)
        
    }
    
    private func setupNavigationBar() {
        titleButton.addTarget(self, action: #selector(showRecipeDropdownMenu), for: .touchUpInside)
    }
    
    private func setupSelectedRecipe() {
        let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        selectedRecipe = recipes.fetchRecipe(with: defaultUUID)!
        updateTitle()
        updateButtons()
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
                self?.updateButtons()
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
            let sampleRecipe1 = SteakRecipe(thickness: 3, initialTemp: 65, ovenTemp: 375, desiredCenterTemp: 144)
            
            let sampleRecipe2 = SteakRecipe(thickness: 4.1, initialTemp: 35, ovenTemp: 250, desiredCenterTemp: 180)
            let sampleRecipe3 = SteakRecipe(thickness: 2, initialTemp: 50, ovenTemp: 310, desiredCenterTemp: 150)

            recipes.addSteakRecipe(sampleRecipe1)
            recipes.addSteakRecipe(sampleRecipe2)
            recipes.addSteakRecipe(sampleRecipe3)
            // Set the flag in UserDefaults
            userDefaults.set(true, forKey: sampleRecipesCreatedKey)
        }
    }
    
    func createSteakRecipe(from cdSteakRecipe: CDSteakRecipe) -> SteakRecipe {
        return SteakRecipe(ID: cdSteakRecipe.id!,
                           thickness: cdSteakRecipe.thickness,
                           initialTemp: cdSteakRecipe.initialTemp,
                           ovenTemp: cdSteakRecipe.ovenTemp,
                           desiredCenterTemp: cdSteakRecipe.desiredCenterTemp)
    }

    
    
    func saveUpdatedRecipeToCoreData() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let cdSteakRecipe = CDSteakRecipe(context: context)

        let newId = UUID()
        let newThickness = Double(lengthLabel.text?.replacingOccurrences(of: " inches", with: "") ?? "0") ?? 0
        let newInitialTemp = steakTemperature.currentValue
        let newOvenTemp = circularSliderTest.currentValue
        let newDesiredCenterTemp = SteakDoneness.temperatureFromDoneness(donenessSlider.currentDoneness)
        
        print("New recipe values:")
        print("ID: \(newId)")
        print("Thickness: \(newThickness) inches")
        print("InitialTemp: \(newInitialTemp)")
        print("OvenTemp: \(newOvenTemp)")
        print("DesiredCenterTemp: \(newDesiredCenterTemp)")
        print("Current Doneness: \(donenessSlider.currentDoneness)")
        
        
        cdSteakRecipe.id = newId
        cdSteakRecipe.thickness = newThickness
        cdSteakRecipe.initialTemp = newInitialTemp
        cdSteakRecipe.ovenTemp = newOvenTemp
        cdSteakRecipe.desiredCenterTemp = newDesiredCenterTemp
        
        do {
            try context.save()
            let newSteakRecipe = createSteakRecipe(from: cdSteakRecipe)
            self.selectedRecipe = newSteakRecipe
            updateTitle()
            print("Recipe successfully saved to Core Data")
            print("Title Updated.")
        } catch {
            print("Failed to save updated recipe to Core Data: \(error.localizedDescription)")
        }
    }


    
    /*
    func saveUpdatedRecipeToCoreData() {
        let context = CoreDataStack.shared.persistentContainer.viewContext

        let cdSteakRecipe = CDSteakRecipe(context: context)
        cdSteakRecipe.id = UUID()
        cdSteakRecipe.thickness = selectedRecipe.thickness
        cdSteakRecipe.initialTemp = selectedRecipe.initialTemp
        cdSteakRecipe.ovenTemp = selectedRecipe.ovenTemp
        cdSteakRecipe.desiredCenterTemp = selectedRecipe.desiredCenterTemp

        // Print the values in the Core Data object
        print("Core Data object values:")
        print("ID: \(cdSteakRecipe.id!)")
        print("Thickness: \(cdSteakRecipe.thickness)")
        print("InitialTemp: \(cdSteakRecipe.initialTemp)")
        print("OvenTemp: \(cdSteakRecipe.ovenTemp)")
        print("DesiredCenterTemp: \(cdSteakRecipe.desiredCenterTemp)")
        print("")

        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("Error saving to Core Data: \(nserror), \(nserror.userInfo)")
        }
    }
*/


    /*
    func saveRecipe() {
        // Update the selectedRecipe with the current values
        selectedRecipe.desiredCenterTemp = SteakDoneness.temperatureFromDoneness(donenessSlider.currentDoneness)
        selectedRecipe.thickness = Double(lengthLabel.text ?? "0") ?? 0
        selectedRecipe.initialTemp = steakTemperature.currentValue
        selectedRecipe.ovenTemp = circularSliderTest.currentValue
        
        // Save the updated recipe to Core Data
        saveUpdatedRecipeToCoreData()
        
        if let lengthText = lengthLabel.text, let lengthValue = Double(lengthText) {
            selectedRecipe.thickness = lengthValue
        }

        // Print the lengthLabel text value and parsed thickness value
        print("lengthLabel.text: \(lengthLabel.text ?? "nil")")
        print("Parsed thickness value: \(selectedRecipe.thickness)")

    }

    */
    @IBAction func saveRecipe(_ sender: Any) {
        saveUpdatedRecipeToCoreData()
    }
    
    @IBAction func showRuler(_ sender: UIButton) {
        let rulerVC = RulerViewController()
        rulerVC.delegate = self
        rulerVC.modalPresentationStyle = .formSheet
        present(rulerVC, animated: true, completion: nil)
    }

    
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension MainViewController: RulerViewControllerDelegate {
    func didSelectLength(length: CGFloat) {
        let lengthRounded = round(length * 10) / 10
        lengthLabel.text = "\(lengthRounded)"
    }
}
