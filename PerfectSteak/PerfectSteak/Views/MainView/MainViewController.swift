//
//  MainViewController.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/25/23.
//


import UIKit
import CoreData
import UserNotifications

class MainViewController: UIViewController, SteakTemperatureDelegate, CircularSliderDelegate, SteakDonenessDelegate {
    
    let networkService = NetworkService()
    
    private var recipes = Recipes()
    private var selectedRecipe: SteakRecipe!
    
    private var recipeDropdownMenu: RecipeDropdownTableViewController?
    private var popoverController: UIPopoverPresentationController?
    
    private var startTime: Date?        // Fix the background countdown stop issue
    private var seconds: Int = 10
    var timer: Timer?           //timer for countdown
    var updateTimer: Timer?      //timer for reset the screen's label
    
    
    ///titleButton: The button for the drop down menue
    @IBOutlet weak var titleButton: UIButton!
    
    @IBOutlet weak var countDownLabel: UILabel!
    
    
    
    ///Parameter IBs:
    ///circularSlider:                           A UIView for              stove temperature
    ///thicknessButton&lengthLabel: Button and label for   steak thickness
    ///donenessSlider:                       A UIView for              doneness
    ///steakTemperature:                   A UIView for              steak initial temperature
    @IBOutlet weak var circularSliderTest: CircularSlider!
    @IBOutlet weak var thicknessButton: UIButton!
    @IBOutlet weak var lengthLabel: UILabel!
    @IBOutlet weak var donenessSlider: DonenessSlider!
    @IBOutlet weak var steakTemperature: SteakTemperature!
    
    ///Save buttons and start button: UIButton
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    private var startButtonClicked = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add observer for the absolute timer
        NotificationCenter.default.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        view.backgroundColor = .black
        //countDownLabel.font = UIFont(name: "LiquidCrystal-Bold", size: 40)
        
        setupNavigationBar()
        
        createSampleRecipes()
        
        setupSelectedRecipe()
        
        steakTemperature.delegate = self
        circularSliderTest.delegate = self
        donenessSlider.delegate = self
        
        /*
         print("doneness: \(String(describing: donenessSlider.steakDonenessTitle.text))")
         print("stove temperature: \(String(describing: circularSliderTest.parameterNumber.text))")
         */
        // Do any additional setup after loading the view.
    }
    
    func steakDonenessValueChanged(to value: SteakDoneness) {
        
        guard timer == nil else { return }      //disable this function when the timer is started
        
        //print("!")
        // Invalidate the previous timer if there's any
        updateTimer?.invalidate()
        
        // Update the countDownLabel immediately
        countDownLabel.text = "Doneness: \n \(value.rawValue)"
        
        // Create a new timer to reset the countDownLabel after 3 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
    
    func steakTemperatureValueChanged(to value: CGFloat) {
        
        guard timer == nil else { return }      //disable this function when the timer is started
        
        // Invalidate the previous timer if there's any
        updateTimer?.invalidate()
        
        // Update the countDownLabel immediately
        countDownLabel.text = "Meat current: \n \(Int(value))°F"
        
        // Create a new timer to reset the countDownLabel after 3 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
    
    func circularSliderValueChanged(to value: CGFloat) {
        
        guard timer == nil else { return }      //disable this function when the timer is started
        
        // Invalidate the previous timer if there's any
        updateTimer?.invalidate()
        
        // Update the countDownLabel immediately
        countDownLabel.text = "Stove: \n \(Int(value))°F"
        
        // Create a new timer to reset the countDownLabel after 3 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
    
    func resetCountDownLabel() {
        countDownLabel.text = "Ready to Deploy"
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
    
    func updateCountDownLabelWithButtonTitles() {
        let stoveTemperature = circularSliderTest.currentValue
        let steakThickness = Double(lengthLabel.text?.replacingOccurrences(of: " inches", with: "") ?? "0") ?? 0
        let donenessText = SteakDoneness.fromTemperature(selectedRecipe.desiredCenterTemp)
        let initialSteakTemperature = steakTemperature.currentValue
        
        countDownLabel.text = "Stove: \(stoveTemperature), Thickness: \(steakThickness), Doneness: \(donenessText), Initial Temp: \(initialSteakTemperature)"
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.countDownLabel.text = ""
        }
    }
    
    
    @objc func didEnterBackground() {
        // Invalidate the timer when the app enters the background
        timer?.invalidate()
    }
    
    @objc func willEnterForeground() {
        // Calculate the remaining time
        if let startTime = startTime {
            let elapsedTime = Date().timeIntervalSince(startTime)
            let remainingTime = max(0, Double(seconds) - elapsedTime)
            
            // Update the seconds value
            seconds = Int(remainingTime)
            
            // If the countdown is not finished, start the timer again
            if seconds > 0 {
                startButtonTapped(startButton)
            } else {
                // If the countdown is finished, update the label and reset the seconds value
                countDownLabel.text = "Time's up!"
                //startButtonClicked = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.countDownLabel.text = ""
                    self.seconds = 10
                }
                
            }
        }
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
            let sampleRecipe1 = SteakRecipe(thickness: 1, initialTemp: 65, ovenTemp: 375, desiredCenterTemp: 135)
            
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
    
    //when a new recipe is selcted, we update new value to 4 buttons
    private func updateButtons() {
        // Implemented currenValue as get set, so angle rotation titles will also be changed
        circularSliderTest.currentValue = selectedRecipe.ovenTemp
        steakTemperature.currentValue = selectedRecipe.initialTemp
        lengthLabel.text = String(selectedRecipe.thickness)
        donenessSlider.currentDoneness = SteakDoneness.fromTemperature(selectedRecipe.desiredCenterTemp)
        
    }
    
    
    func saveUpdatedRecipeToCoreData() {
        let context = CoreDataStack.shared.persistentContainer.viewContext
        let cdSteakRecipe = CDSteakRecipe(context: context)
        
        let newId = UUID()
        let newThickness = Double(lengthLabel.text?.replacingOccurrences(of: " inches", with: "") ?? "0") ?? 0
        let newInitialTemp = steakTemperature.currentValue
        let newOvenTemp = circularSliderTest.currentValue
        let newDesiredCenterTemp = SteakDoneness.temperatureFromDoneness(donenessSlider.currentDoneness)
        /*
        print("New recipe values:")
        print("ID: \(newId)")
        print("Thickness: \(newThickness) inches")
        print("InitialTemp: \(newInitialTemp)")
        print("OvenTemp: \(newOvenTemp)")
        print("DesiredCenterTemp: \(newDesiredCenterTemp)")
        print("Current Doneness: \(donenessSlider.currentDoneness)")
        */
        
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
        saveUpdatedRecipeToCoreData()
        contentSaved()
    }
    
    
    func contentSaved() {
        
        guard timer == nil else { return }
              
        // Invalidate the previous timer if there's any
        updateTimer?.invalidate()

        // Update the countDownLabel immediately
        countDownLabel.text = "Recipe saved"

        // Create a new timer to reset the countDownLabel after 1 seconds
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
            self?.resetCountDownLabel()
        }
    }
    
    
    @IBAction func showRuler(_ sender: UIButton) {
        let rulerVC = RulerViewController()
        rulerVC.delegate = self
        rulerVC.modalPresentationStyle = .formSheet
        present(rulerVC, animated: true, completion: nil)
    }
    
    @IBAction func startButtonTapped(_ sender: UIButton) {
        if !startButtonClicked {     // not cooking now
            startButtonClicked = true
            startButton.setImage(UIImage(systemName: "stop"), for: .normal)
            startCountDown()
        } else {                    // cooking now
            //It's already started the countdown.
            //cancel the timer
            cancelCooking()
            startButton.setImage(UIImage(systemName: "stove"), for: .normal)
        }
        
    }
    
    func cancelCooking() {
        timer?.invalidate()
        timer = nil
        seconds = 10
        countDownLabel.text = "Cooking cancelled"
        startButtonClicked = false

        // Clear the label after 1 second
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.countDownLabel.text = "Ready to Deploy"
        }

        // Remove the pending notification
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["countdownFinished"])
    }

    private func startCountDown() {
        // Invalidate any existing timer
        timer?.invalidate()

        // Display "Calculating..." before the countdown starts
        countDownLabel.text = "Calculating..."

         let newThickness = Double(lengthLabel.text?.replacingOccurrences(of: " inches", with: "") ?? "0") ?? 0
         let newInitialTemp = steakTemperature.currentValue
         let newOvenTemp = circularSliderTest.currentValue
         let newDesiredCenterTemp = SteakDoneness.temperatureFromDoneness(donenessSlider.currentDoneness)

        // Make the HTTP request to get the cooking time
        networkService.getSteakCookingTime(steakTemperature: newInitialTemp, ovenTemperature: newOvenTemp, steakThickness: newThickness, steakDoneness: newDesiredCenterTemp) { [weak self] (result) in
            guard let self = self else { return }

            switch result {
            case .success(var seconds):
                seconds = seconds * 2
                self.sendNotification(timeInterval: TimeInterval(seconds))

                // Update the seconds
                self.seconds = seconds

                // Start the countdown
                DispatchQueue.main.async {
                    self.startTimer()
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.countDownLabel.text = "Error: \(error.localizedDescription)"
                }
            }
        }
    }


    private func startTimer() {
        
        if !startButtonClicked { return }
        
        // Invalidate any existing timer
        timer?.invalidate()

        // Start a new timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Update the seconds
            self.seconds -= 1

            // If the countdown reaches zero, invalidate the timer
            if self.seconds <= 0 {
                self.timer?.invalidate()
                self.timer = nil

                // Update the label to show "Time's up!"
                self.countDownLabel.text = "Time's up!"
                startButtonClicked = false
                startButton.setImage(UIImage(systemName: "stove"), for: .normal)

                // Clear the label and reset the seconds value after 1 second
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.countDownLabel.text = "Ready to Deploy"
                    self.seconds = 10
                }
            } else {
                // Update the label
                self.updateCountDownLabel()
            }
        }
    }

    
    func sendNotification(timeInterval: TimeInterval) {
        //print("sendNotification called")
        
        // Create a notification content
        let content = UNMutableNotificationContent()
        content.title = "Time's up!"
        content.body = "Your steak is ready"

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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

