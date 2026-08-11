//
//  MainViewController.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/25/23.
//

import StoreKit
import UIKit
import CoreData
import UserNotifications

class MainViewController: UIViewController, SteakTemperatureDelegate, CircularSliderDelegate, SteakDonenessDelegate, SteakTemperatureNumberPadDelegate, CircularSliderNumberPadDelegate {
    
    let networkService = NetworkService()

    ///recipes and selected recipe
    private var recipes = Recipes()
    private var selectedRecipe: SteakRecipe!
    private var recipeDropdownMenu: RecipeDropdownTableViewController?
    private var popoverController: UIPopoverPresentationController?
    
    ///timer
    private var startTime: Date?        // Fix the background countdown stop issue
    private var seconds: Int = 0
    private var totalSeconds: Int = 0
    var timer: Timer?           //timer for countdown
    var updateTimer: Timer?      //timer for reset the screen's label
    private var isUpdatingButtons = false
    var task: UUID?
    var dataTask: URLSessionDataTask?

    

    ///titleButton: The button for the drop down menue
    @IBOutlet weak var titleButton: UIButton!
    @IBOutlet weak var countDownLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    
    ///unit selection
    var appLanguage = AppLocalization.currentLanguage
    private var temperatureUnit = UserDefaults.standard.string(forKey: "TemperatureUnit") ?? "F"
    var usesFahrenheit: Bool {
        temperatureUnit == "F"
    }
    @IBOutlet weak var languageSegmentedControl: UISegmentedControl!
    private let temperatureUnitSwitcherView = UIView()
    private let fahrenheitButton = UIButton(type: .system)
    private let celsiusButton = UIButton(type: .system)
    private let myRecipesButton = UIButton(type: .system)
    private let instructionsButton = UIButton(type: .system)
    private let saveActionButton = UIButton(type: .system)
    private let cookActionButton = UIButton(type: .system)
    @IBAction func languageChanged(_ sender: UISegmentedControl) {
        temperatureUnit = sender.selectedSegmentIndex == 0 ? "F" : "C"
        UserDefaults.standard.set(temperatureUnit, forKey: "TemperatureUnit")
        UserDefaults.standard.synchronize()
        circularSliderTest.updateLanguage()
        steakTemperature.updateLanguage()
        thicknessUpdateLanguage()
        updateTemperatureUnitSwitcherSelection()
        updateButtons()
    }
    
    ///Parameter IBs:
    ///circularSlider:                           A UIView for              stove temperature
    ///thicknessButton&lengthLabel: Button and label for   steak thickness
    ///donenessSlider:                       A UIView for              doneness
    ///steakTemperature:                   A UIView for              steak initial temperature
    @IBOutlet weak var circularSliderTest: CircularSlider!
    @IBOutlet weak var thicknessButton: UIButton!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var lengthTitle: UILabel!
    @IBOutlet weak var lengthUnit: UILabel!
    @IBOutlet weak var donenessSlider: DonenessSlider!
    @IBOutlet weak var steakTemperature: SteakTemperature!
    
    @IBOutlet weak var cookLabel: UILabel!
    @IBOutlet weak var saveLabel: UILabel!
    
    private func thicknessUpdateLanguage() {
        lengthTitle.text = L("Thickness")
        lengthUnit.text = usesFahrenheit ? "\"" : "cm"
    }
    
    private func saveCookUpdateLanguage() {
        saveLabel.text = L("Save")
        cookLabel.text = L("Cook")
        saveActionButton.setTitle(L("Save"), for: .normal)
        cookActionButton.setTitle(L("Cook"), for: .normal)
    }
    
    private func titleButtonUpdateLanguage() {
        titleButton.setTitle(L("MY RECIPES"), for: .normal)
        myRecipesButton.setTitle(L("My Recipes"), for: .normal)
        myRecipesButton.accessibilityLabel = L("My Recipes")
    }
    ///User guide
    private let guideTool = FeatureGuideTool(identifier: "homeGuide", insideMargin: .zero)
    
    ///Save buttons and start button: UIButton
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    private var startButtonClicked = false
    private var rulerTransitioningDelegate: RulerTransitioningDelegate?
    private var debouncedActionTimestamps: [String: Date] = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        steakTemperature.bringSubviewToFront(steakTemperature.informationButton)

        infoLabel.text = ""
        // add observer for the absolute timer
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
     
        view.backgroundColor = .black
        

        
        //countDownLabel.font = UIFont(name: "LiquidCrystal-Bold", size: 40)
        thicknessButton.layer.borderColor = UIColor.lightGray.cgColor
        thicknessButton.layer.borderWidth = 2
        thicknessButton.layer.cornerRadius = 50
        thicknessButton.backgroundColor = UIColor(red: 66/255, green: 66/255, blue: 66/255, alpha: 1)
        languageSegmentedControl.overrideUserInterfaceStyle = .dark
        setupParameterGridPosition()
        setupTopActionRow()
        setupPrimaryActionButtons()

        //setupNavigationBar()
        
        createSampleRecipes()
        
        setupSelectedRecipe()
        
        steakTemperature.numberPadDelegate = self
        steakTemperature.delegate = self
        circularSliderTest.delegate = self
        circularSliderTest.numberPadDelegate = self
        donenessSlider.delegate = self
        showGuideIfNeeded()
        
        ///unit setting
        languageSegmentedControl.setTitle("°F", forSegmentAt: 0)
        languageSegmentedControl.setTitle("°C", forSegmentAt: 1)
        temperatureUnit = UserDefaults.standard.string(forKey: "TemperatureUnit") ?? "F"
        languageSegmentedControl.selectedSegmentIndex = usesFahrenheit ? 0 : 1
        updateTemperatureUnitSwitcherSelection()
        donenessSlider.updateLanguage()
        circularSliderTest.updateLanguage()
        steakTemperature.updateLanguage()
        thicknessUpdateLanguage()
        saveCookUpdateLanguage()
        titleButtonUpdateLanguage()
        updateButtons()
    }

    private func setupParameterGridPosition() {
        steakTemperature.superview?.superview?.transform = CGAffineTransform(translationX: 0, y: 0)
    }

    private func setupTopActionRow() {
        let segmentedConstraints = view.constraints.filter { constraint in
            constraint.firstItem === languageSegmentedControl || constraint.secondItem === languageSegmentedControl
        }
        NSLayoutConstraint.deactivate(segmentedConstraints)

        languageSegmentedControl.isHidden = true
        setupTemperatureUnitSwitcher()

        configureTopRowButton(myRecipesButton, title: L("My Recipes"))
        myRecipesButton.accessibilityLabel = L("My Recipes")
        myRecipesButton.addTarget(self, action: #selector(showRecipesFromTopRow), for: .touchUpInside)
        view.addSubview(myRecipesButton)

        configureTopRowButton(instructionsButton, title: L("Instructions"))
        instructionsButton.accessibilityLabel = L("Instructions")
        instructionsButton.addTarget(self, action: #selector(showInstructions), for: .touchUpInside)
        view.addSubview(instructionsButton)

        guard let screenView = countDownLabel.superview else { return }
        screenView.layer.cornerRadius = 16
        screenView.layer.masksToBounds = true

        NSLayoutConstraint.activate([
            temperatureUnitSwitcherView.topAnchor.constraint(equalTo: screenView.bottomAnchor, constant: 10),
            temperatureUnitSwitcherView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 27),
            temperatureUnitSwitcherView.widthAnchor.constraint(equalToConstant: 92),
            temperatureUnitSwitcherView.heightAnchor.constraint(equalToConstant: 32),

            instructionsButton.centerYAnchor.constraint(equalTo: temperatureUnitSwitcherView.centerYAnchor),
            instructionsButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -27),
            instructionsButton.widthAnchor.constraint(equalToConstant: 104),
            instructionsButton.heightAnchor.constraint(equalToConstant: 32),

            myRecipesButton.centerYAnchor.constraint(equalTo: temperatureUnitSwitcherView.centerYAnchor),
            myRecipesButton.trailingAnchor.constraint(equalTo: instructionsButton.leadingAnchor, constant: -8),
            myRecipesButton.leadingAnchor.constraint(greaterThanOrEqualTo: temperatureUnitSwitcherView.trailingAnchor, constant: 8),
            myRecipesButton.widthAnchor.constraint(equalToConstant: 104),
            myRecipesButton.heightAnchor.constraint(equalToConstant: 32)
        ])
    }

    private func setupTemperatureUnitSwitcher() {
        temperatureUnitSwitcherView.translatesAutoresizingMaskIntoConstraints = false
        temperatureUnitSwitcherView.backgroundColor = UIColor(white: 0.18, alpha: 1)
        temperatureUnitSwitcherView.layer.cornerRadius = 16
        temperatureUnitSwitcherView.layer.masksToBounds = true
        view.addSubview(temperatureUnitSwitcherView)

        configureTemperatureUnitButton(fahrenheitButton, title: "°F")
        configureTemperatureUnitButton(celsiusButton, title: "°C")
        fahrenheitButton.addTarget(self, action: #selector(temperatureUnitButtonTapped(_:)), for: .touchUpInside)
        celsiusButton.addTarget(self, action: #selector(temperatureUnitButtonTapped(_:)), for: .touchUpInside)
        temperatureUnitSwitcherView.addSubview(fahrenheitButton)
        temperatureUnitSwitcherView.addSubview(celsiusButton)

        NSLayoutConstraint.activate([
            fahrenheitButton.leadingAnchor.constraint(equalTo: temperatureUnitSwitcherView.leadingAnchor),
            fahrenheitButton.topAnchor.constraint(equalTo: temperatureUnitSwitcherView.topAnchor),
            fahrenheitButton.bottomAnchor.constraint(equalTo: temperatureUnitSwitcherView.bottomAnchor),
            fahrenheitButton.widthAnchor.constraint(equalTo: temperatureUnitSwitcherView.widthAnchor, multiplier: 0.5),

            celsiusButton.trailingAnchor.constraint(equalTo: temperatureUnitSwitcherView.trailingAnchor),
            celsiusButton.topAnchor.constraint(equalTo: temperatureUnitSwitcherView.topAnchor),
            celsiusButton.bottomAnchor.constraint(equalTo: temperatureUnitSwitcherView.bottomAnchor),
            celsiusButton.widthAnchor.constraint(equalTo: fahrenheitButton.widthAnchor)
        ])
    }

    private func configureTemperatureUnitButton(_ button: UIButton, title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
    }

    private func updateTemperatureUnitSwitcherSelection() {
        fahrenheitButton.backgroundColor = usesFahrenheit ? UIColor(white: 0.333, alpha: 1) : .clear
        celsiusButton.backgroundColor = usesFahrenheit ? .clear : UIColor(white: 0.333, alpha: 1)
        fahrenheitButton.accessibilityTraits = usesFahrenheit ? [.button, .selected] : .button
        celsiusButton.accessibilityTraits = usesFahrenheit ? .button : [.button, .selected]
    }

    @objc private func temperatureUnitButtonTapped(_ sender: UIButton) {
        languageSegmentedControl.selectedSegmentIndex = sender === fahrenheitButton ? 0 : 1
        languageChanged(languageSegmentedControl)
        updateTemperatureUnitSwitcherSelection()
    }

    private func configureTopRowButton(_ button: UIButton, title: String) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 13, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(white: 0.18, alpha: 1)
        button.layer.borderWidth = 0
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }

    private func setupPrimaryActionButtons() {
        // Storyboard save/cook controls remain connected for existing logic, but are replaced visually by capsule buttons.
        saveButton.isHidden = true
        startButton.isHidden = true
        saveLabel.isHidden = true
        cookLabel.isHidden = true

        configureCapsuleButton(saveActionButton, title: L("Save"), backgroundColor: UIColor(white: 0.333, alpha: 1))
        configureCapsuleButton(cookActionButton, title: L("Cook"), backgroundColor: UIColor(red: 1, green: 0.365, blue: 0.196, alpha: 1))
        saveActionButton.addTarget(self, action: #selector(saveRecipe(_:)), for: .touchUpInside)
        cookActionButton.addTarget(self, action: #selector(startButtonTapped(_:)), for: .touchUpInside)
        view.addSubview(saveActionButton)
        view.addSubview(cookActionButton)

        NSLayoutConstraint.activate([
            cookActionButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -27),
            cookActionButton.centerXAnchor.constraint(equalTo: thicknessButton.centerXAnchor),
            cookActionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -28),
            cookActionButton.heightAnchor.constraint(equalToConstant: 44),

            saveActionButton.centerXAnchor.constraint(equalTo: steakTemperature.centerXAnchor),
            saveActionButton.widthAnchor.constraint(equalTo: cookActionButton.widthAnchor),
            saveActionButton.centerYAnchor.constraint(equalTo: cookActionButton.centerYAnchor),
            saveActionButton.heightAnchor.constraint(equalTo: cookActionButton.heightAnchor)
        ])
    }

    private func configureCapsuleButton(_ button: UIButton, title: String, backgroundColor: UIColor) {
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = backgroundColor
        button.layer.cornerRadius = 22
        button.layer.masksToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    }

    private func setCookActionTitle(_ key: String) {
        cookActionButton.setTitle(L(key), for: .normal)
    }

    private func shouldRunDebouncedAction(_ key: String, interval: TimeInterval = 0.45) -> Bool {
        let now = Date()
        if let lastRun = debouncedActionTimestamps[key], now.timeIntervalSince(lastRun) < interval {
            return false
        }
        debouncedActionTimestamps[key] = now
        return true
    }

    @objc private func showRecipesFromTopRow() {
        guard shouldRunDebouncedAction("recipesMenu") else { return }
        showRecipeDropdownMenu(from: titleButton)
    }

    @objc private func showInstructions() {
        guard shouldRunDebouncedAction("instructions"), presentedViewController == nil else { return }
        let instructionsViewController = InstructionsViewController()
        let navigationController = UINavigationController(rootViewController: instructionsViewController)
        navigationController.modalPresentationStyle = .pageSheet
        present(navigationController, animated: true)
    }
   
    private func showGuideIfNeeded() {
        var hollowOutModels = [HollowOutModel]()
        let taptoEnterModel = HollowOutModel(type: .view(circularSliderTest.circularButton)) { _ in
            let style = HomeGideView.Style.taptoEnter
            let view = HomeGideView(style)
            view.frame = CGRect(x: 0, y: 0, width: LayoutConstants.deviceWidth, height: style.imageViewSize.height)
            return view
        }
        
        taptoEnterModel.isCircle = true
        taptoEnterModel.cornerRadius = 50
        taptoEnterModel.verticalMargin = 10
        taptoEnterModel.isShowDashed = false
        hollowOutModels.append(taptoEnterModel)

        let calculateModel = HollowOutModel(type: .view(cookActionButton)) { _ in
            let style = HomeGideView.Style.calculate
            let view = HomeGideView(style)
            view.frame = CGRect(x: 0, y: 0, width: LayoutConstants.deviceWidth, height: style.imageViewSize.height)
            return view
        }
        
        calculateModel.isCircle = true
        calculateModel.cornerRadius = 32.5
        calculateModel.verticalMargin = 10
        calculateModel.isShowDashed = false
        calculateModel.isUnderRelativeView = true
        hollowOutModels.append(calculateModel)
        guideTool.start(hollowOutModels)
    }
    
    // Information button
    func didTapButton() {
        infoLabel.text = L("Room temperature recommended")
        print("Information button appLanguage: \(appLanguage)")
        
        // Clear the label after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.infoLabel.text = ""
        }
    }
    
    private func resetTimer() {
        self.timer?.invalidate()
        self.timer = nil
        
        self.countDownLabel.text = L("Time's Up")
        self.infoLabel.text = " "
        
        startButton.setImage(UIImage(systemName: "oven"), for: .normal)
        setCookActionTitle("Cook")

        // Clear the label and reset the seconds value after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.startButtonClicked = false
            self.countDownLabel.text = L("Ready to Cook")
            self.infoLabel.text = " "
            self.seconds = 0
        }
    }

    func steakDonenessValueChanged(to value: SteakDoneness) {
        
        guard timer == nil, !isUpdatingButtons else { return }      //disable this function when the timer is started
        
        //print("!")
        // Invalidate the previous steak status timer if there's any
        updateTimer?.invalidate()
        
        // Update the countDownLabel immediately
        countDownLabel.text = LF("Doneness Status", value.localized)
        
        // Create a new timer to reset the countDownLabel after 3 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
    
    func steakTemperatureValueChanged(to value: CGFloat) {
        
        guard timer == nil, !isUpdatingButtons else { return }      //disable this function when the timer is started
        
        // Invalidate the previous steak status timer if there's any
        updateTimer?.invalidate()
        
        // Update the countDownLabel immediately
        let unitText = usesFahrenheit ? "F" : "C"
        countDownLabel.text = LF("Meat Current Status", Int(value), unitText)
        
        //Update the selected receipe
        selectedRecipe.initialTemp = Double(usesFahrenheit ? Int(value) : toFahrenheit(Int(value)))
        
        // Create a new timer to reset the countDownLabel after 3 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
    
    func circularSliderValueChanged(to value: CGFloat) {
        
        guard timer == nil, !isUpdatingButtons else { return }      //disable this function when the timer is started
        
        // Invalidate the previous steak status timer if there's any
        updateTimer?.invalidate()
        
        // Update the countDownLabel immediately
        let unitText = usesFahrenheit ? "F" : "C"
        countDownLabel.text = LF("Stove Status", Int(value), unitText)
        
        // Update the selected receipe
        selectedRecipe.ovenTemp = Double(usesFahrenheit ? Int(value) : toFahrenheit(Int(value)))
        
        // Create a new timer to reset the countDownLabel after 3 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
    
    func resetCountDownLabel() {
        countDownLabel.text = L("Ready to Cook")
       // infoLabel.text = " "
    }
    
    
    /*
    private func setupNavigationBar() {
        titleButton.addTarget(self, action: #selector(showRecipeDropdownMenu), for: .touchUpInside)
    }
    */
    
    private func setupSelectedRecipe() {
        let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        selectedRecipe = recipes.fetchRecipe(with: defaultUUID)!
        updateTitle()
        updateButtons()
    }
    
    
    private func updateTitle() {
        let button = navigationItem.titleView as? UIButton
        button?.setTitle(selectedRecipe.title, for: .normal)
        titleButtonUpdateLanguage()
    }
    
    func updateCountDownLabelWithButtonTitles() {
        let stoveTemperature = circularSliderTest.currentValue
        let steakThickness = Double(lengthLabel.text?.replacingOccurrences(of: " inches", with: "") ?? "0") ?? 0
        let donenessText = SteakDoneness.fromTemperature(selectedRecipe.desiredCenterTemp).localized
        let initialSteakTemperature = steakTemperature.currentValue
        
        countDownLabel.text = LF("Parameter Summary", String(describing: stoveTemperature), steakThickness, donenessText, String(describing: initialSteakTemperature))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.countDownLabel.text = ""
            self.infoLabel.text = " "
        }
    }
    


    
    @IBAction func recipesDropDownMenuClicked(_ sender: Any) {
        guard shouldRunDebouncedAction("recipesMenu") else { return }
        showRecipeDropdownMenu(from: titleButton)
        //print("Herere")
    }
    
    private func showRecipeDropdownMenu(from sourceView: UIView) {
        let menu = RecipeDropdownTableViewController()
        menu.modalPresentationStyle = .popover
        menu.preferredContentSize = CGSize(width: 310, height: 130)
        menu.recipesManager = recipes
        menu.recipes = recipes.steakRecipes
        menu.didSelectRecipe = { [weak self] recipe in
            self?.selectedRecipe = recipe
            self?.updateTitle()
            self?.updateButtons()
        }
        titleButtonUpdateLanguage()
        popoverController = menu.popoverPresentationController
        popoverController?.delegate = self
        popoverController?.sourceView = sourceView
        popoverController?.sourceRect = sourceView.bounds
        popoverController?.permittedArrowDirections = .any
            
        present(menu, animated: true, completion: nil)
    }

    
    func createSampleRecipes() {
        let userDefaults = UserDefaults.standard
        let sampleRecipesCreatedKey = "sampleRecipesCreated"
        
        if !userDefaults.bool(forKey: sampleRecipesCreatedKey) {
            let sampleRecipe1 = SteakRecipe(thickness: 1, initialTemp: 10, ovenTemp: 350, desiredCenterTemp: 135)
            
            //let sampleRecipe2 = SteakRecipe(thickness: 4.1, initialTemp: 35, ovenTemp: 250, desiredCenterTemp: 180)
            //let sampleRecipe3 = SteakRecipe(thickness: 2, initialTemp: 50, ovenTemp: 310, desiredCenterTemp: 150)
            
            recipes.addSteakRecipe(sampleRecipe1)
            //recipes.addSteakRecipe(sampleRecipe2)
            //recipes.addSteakRecipe(sampleRecipe3)
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

    private func currentThicknessInInches() -> CGFloat {
        let displayedThickness = Double(lengthLabel.text ?? "") ?? 1
        let thicknessInInches = usesFahrenheit ? displayedThickness : displayedThickness * 0.393701
        return CGFloat(max(thicknessInInches, 0.1))
    }
    
    //when a new recipe is selcted, we update new value to 4 buttons
    private func updateButtons() {
        isUpdatingButtons = true
        defer { isUpdatingButtons = false }
        // Implemented currenValue as get set, so angle rotation titles will also be changed
        circularSliderTest.currentValue = CGFloat(usesFahrenheit ? Int(selectedRecipe.ovenTemp) : toCelsius(Int(selectedRecipe.ovenTemp)))
        //steakTemperature.currentValue = selectedRecipe.initialTemp
        steakTemperature.currentValue = CGFloat(usesFahrenheit ? Int(selectedRecipe.initialTemp) : toCelsius(Int(selectedRecipe.initialTemp)))
        let displayedThickness = usesFahrenheit ? selectedRecipe.thickness : selectedRecipe.thickness * 2.54
        lengthLabel.text = String(format: "%.1f", displayedThickness)
        donenessSlider.currentDoneness = SteakDoneness.fromTemperature(selectedRecipe.desiredCenterTemp)
        
    }
    
    
    func saveUpdatedRecipeToCoreData() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let cdSteakRecipe = CDSteakRecipe(context: context)
        
        let newId = UUID()
        //print("length label when save: \(lengthLabel.text)")
        let displayedThickness = Double(lengthLabel.text ?? "0") ?? 0
        let newThickness = usesFahrenheit ? displayedThickness : displayedThickness * 0.393701
        let newInitialTemp = Double(usesFahrenheit ? Int(steakTemperature.currentValue) : toFahrenheit(Int(steakTemperature.currentValue)))
        let newOvenTemp = Double(usesFahrenheit ? Int(circularSliderTest.currentValue) : toFahrenheit(Int(circularSliderTest.currentValue)))
        let newDesiredCenterTemp = SteakDoneness.temperatureFromDoneness(donenessSlider.currentDoneness)
        
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
            //print("Recipe successfully saved to Core Data")
            //print("Title Updated.")
        } catch {
            print("Failed to save updated recipe to Core Data: \(error.localizedDescription)")
        }
    }

    
    func updateCountDownLabel() {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        let remainingSeconds = seconds % 60
        
        countDownLabel.text = String(format: "%02d : %02d : %02d", hours, minutes, remainingSeconds)
    }
    
    
    
    @IBAction func saveRecipe(_ sender: Any) {
        guard shouldRunDebouncedAction("saveRecipe", interval: 0.8) else { return }
        saveUpdatedRecipeToCoreData()
        contentSaved()
    }
    
    
    func contentSaved() {
        
        guard timer == nil else { return }
              
        // Invalidate the previous timer if there's any
        updateTimer?.invalidate()

        // Update the countDownLabel immediately
        countDownLabel.text = L("Saved to My Recipes")

        // Create a new timer to reset the countDownLabel after 1 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
    
    
    @IBAction func showRuler(_ sender: UIButton) {
        guard shouldRunDebouncedAction("showRuler"), presentedViewController == nil else { return }
        let rulerVC = RulerViewController()
        rulerVC.delegate = self
        rulerVC.initialLengthInInches = currentThicknessInInches()
        let navigationController = UINavigationController(rootViewController: rulerVC)
        let transition = RulerTransitioningDelegate(sourceView: sender)
        rulerTransitioningDelegate = transition
        navigationController.transitioningDelegate = transition
        navigationController.modalPresentationStyle = .custom
        present(navigationController, animated: true, completion: nil)
    }

    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        guard shouldRunDebouncedAction("startButton", interval: 0.35) else { return }
        if !startButtonClicked {     // not cooking now
            startButtonClicked = true
            //startButton.isEnabled = false // Disable the button
            startButton.setImage(UIImage(systemName: "xmark"), for: .normal)
            setCookActionTitle("Cancel")
            startCalculation()
            
            if let scene = view.window?.windowScene {
                print("Requesting App Store Review")
                       SKStoreReviewController.requestReview(in: scene)
            }
        } else {                    // calculating or cooking now
            if task != nil {
                cancelCalculation()
            } else if timer == nil { // Button tapped to start the countdown
                startTimer()
                startButton.setImage(UIImage(systemName: "stop"), for: .normal)
                setCookActionTitle("Stop")
            } else { // Button tapped to stop the countdown
                //cancel the timer
                cancelCooking()
                startButton.setImage(UIImage(systemName: "oven"), for: .normal)
                setCookActionTitle("Cook")
            }
        }
    }
    
    func cancelCalculation() {
        task = nil
        dataTask?.cancel()
        countDownLabel.text = L("Cooking cancelled")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.countDownLabel.text = L("Ready to Cook")
            self.infoLabel.text = " "
        }
        startButton.setImage(UIImage(systemName: "oven"), for: .normal)
        setCookActionTitle("Cook")
        startButtonClicked = false
    }

    
    func cancelCooking() {
        timer?.invalidate()
        timer = nil
        task = nil
        //seconds = 10
        //Cooking cancelled was hit
        countDownLabel.text = L("Cooking cancelled")
        startButtonClicked = false

        // Clear the label after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.countDownLabel.text = L("Ready to Cook")
            self.infoLabel.text = " "
        }

        // Remove the pending notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["countdownFinished"])
    }
    
    

    private func toFahrenheit(_ temp: Int) -> Int {
        return Int(Double(temp) * 9.0 / 5.0 + 32)
    }


    private func toCelsius(_ temp: Int) -> Int {
        return Int((Double(temp) - 32) * 5.0 / 9.0)
    }
    
    private func startCalculation() {
        // Invalidate any existing timer
        timer?.invalidate()

        // Display "Calculating..." before the countdown starts
        countDownLabel.text = L("Calculating...")
        infoLabel.text = L("Thicker meat calculates longer")
        
       // startButton.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
    
        
        var newThickness: Double = 0

        if usesFahrenheit {
            newThickness = Double(lengthLabel.text ?? "0") ?? 0
        } else if let thicknessInCm = Double(lengthLabel.text ?? "0") {
            newThickness = thicknessInCm * 0.393701
        }

        print("Selected thickness: \(selectedRecipe.thickness)")
        let newInitialTemp = usesFahrenheit ? Int(steakTemperature.currentValue) : toFahrenheit(Int(steakTemperature.currentValue))
        let newOvenTemp = usesFahrenheit ? Int(circularSliderTest.currentValue) : toFahrenheit(Int(circularSliderTest.currentValue))
        let newDesiredCenterTemp = SteakDoneness.temperatureFromDoneness(donenessSlider.currentDoneness)
        let taskId = UUID()
        task = taskId
        // Make the HTTP request to get the cooking time
        dataTask = networkService.getSteakCookingTime(steakTemperature: Double(newInitialTemp), ovenTemperature: Double(newOvenTemp), steakThickness: newThickness, steakDoneness: newDesiredCenterTemp) { [weak self] (result) in
            guard let self = self else { return }
            print("============= Current task: \(String(describing: task))")
            guard taskId == task else { return }
            print("============= Current task exist: \(String(describing: task))")

            switch result {
            case .success(let seconds):
                //print("seconds: \(seconds)")
                //print("")
                //seconds = seconds * 2
                self.sendNotification(timeInterval: TimeInterval(seconds))

                // Update the seconds
                self.seconds = Int(seconds)
                self.totalSeconds = Int(seconds)
                // Start the countdown
                DispatchQueue.main.async {
                    self.startButton.isEnabled = true
                    self.updateCountDownLabel()
                    self.startButton.setImage(UIImage(systemName: "play"), for: .normal)
                    self.setCookActionTitle("Start")
                    self.infoLabel.text = L("Ready to countdown")
                }
                self.task = nil
            case .failure(let error):
                DispatchQueue.main.async {
                    self.countDownLabel.text = LF("Error Format", error.localizedDescription)
                    self.infoLabel.text = " "
                    self.startButton.isEnabled = true // Enable the button in case of failure
                    self.startButton.setImage(UIImage(systemName: "oven"), for: .normal) // Reset the button image
                    self.setCookActionTitle("Cook")
                    self.startButtonClicked = false // Reset the startButtonClicked flag
                }
                self.task = nil
            }
        }
    }

    @objc func didEnterBackground() {
        // Invalidate the timer when the app enters the background
        timer?.invalidate()
    }
    
    @objc func willEnterForeground() {
        print("_______")
        print("App entered foreground")
        if startButtonClicked {
            // Calculate the remaining time
            let elapsedTime = Date().timeIntervalSince(startTime!)
            let remainingTime = max(0, Double(totalSeconds) - elapsedTime)   //ensure the remaining time >= 0
            let now = Date()
            print("Start time: \(startTime!.description)")
            print("Now time: \(now.description)")
            print("Total seconds: \(totalSeconds.description)")
            print("Elapsed time: \(elapsedTime.description)")
            print("Remaining time: \(remainingTime.description)")

            // Update the total seconds value to new remaining time
            seconds = Int(remainingTime)

            // If the countdown is not finished, start the timer again
            if seconds > 0 {
                print("start button clicked? \(startButtonClicked)")
                /*
                 Bug behavior: when coming back to the foreground
                 */
                resumeTimer()
            } else {
                resetTimer()
                print("reset timer is called _____________")
            }
        }

    }
    
    private func resumeTimer() {
        if !startButtonClicked { return }
        
        // Invalidate any existing timer
        timer?.invalidate()
        //startTime = Date()
        
        // Start a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Update the seconds
            self.seconds -= 1

            // If the countdown reaches zero, invalidate the timer
            if self.seconds <= 0  {
                resetTimer()
            } else {
                // Update the label
                self.updateCountDownLabel()
            }
        }
    }

    
    private func startTimer() {
        if !startButtonClicked { return }
        
        // Invalidate any existing timer
        timer?.invalidate()
        startTime = Date()
        self.infoLabel.text = " "
        // Start a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Update the seconds
            self.seconds -= 1

            // If the countdown reaches zero, invalidate the timer
            if self.seconds <= 0  {
                resetTimer()
            } else {
                // Update the label
                self.updateCountDownLabel()
            }
        }
    }

    
    func sendNotification(timeInterval: TimeInterval) {
        //print("sendNotification called")
        if timeInterval < 0 {
            return
        }
        // Create a notification content
        let content = UNMutableNotificationContent()
        content.title = L("Time's up!")
        content.body = L("Your steak is ready")

        // Create a notification trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)

        // Create a notification request
        let request = UNNotificationRequest(identifier: "countdownFinished", content: content, trigger: trigger)

        // Add the request to the notification center
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Failed to send notification: \(error.localizedDescription)")
            } else {
                print("Notification request added successfully")
            }
        }
    }

    func showNumberPad(for steakTemperature: SteakTemperature) {
        let numberPadView = NumberPadView(frame: CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height))
        numberPadView.delegate = steakTemperature
        numberPadView.textField.text = steakTemperature.parameterNumber.text
        self.view.addSubview(numberPadView)

        UIView.animate(withDuration: 0.3, animations: {
            numberPadView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        })
    }
    
    func showNumberPad(for circularSlider: CircularSlider) {
        let numberPadView = NumberPadView(frame: CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height))
        numberPadView.delegate = circularSlider
        numberPadView.textField.text = circularSlider.parameterNumber.text
        self.view.addSubview(numberPadView)

        UIView.animate(withDuration: 0.3, animations: {
            numberPadView.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        })
    }
    
    func dismissNumberPadView() {
        if let numberPadView = self.view.subviews.first(where: { $0 is NumberPadView }) {
            UIView.animate(withDuration: 0.3, animations: {
                numberPadView.frame = CGRect(x: 0, y: self.view.bounds.height, width: self.view.bounds.width, height: self.view.bounds.height)
            }, completion: { _ in
                numberPadView.removeFromSuperview()
            })
        }
    }


    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        
        print("View controller deallocated")
    }

}

