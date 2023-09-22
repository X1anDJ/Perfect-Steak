//
//  RecipeDropdownTableViewController.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/25/23.
//

import UIKit

class RecipeDropdownTableViewController: UITableViewController {

    var recipesManager: Recipes = Recipes()
    var recipes: [SteakRecipe] = []
    var didSelectRecipe: ((SteakRecipe) -> Void)?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(RecipeTableViewCell.self, forCellReuseIdentifier: "recipeCell")
        tableView.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 102/255, alpha: 1)
        tableView.separatorColor = .lightGray
        //tableView.layer.borderWidth = 3
        //tableView.layer.borderColor = UIColor.lightGray.cgColor
    }

    // MARK: - Table view data source

    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return recipes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recipeCell", for: indexPath) as! RecipeTableViewCell
        let recipe = recipes[indexPath.row]
        cell.configure(with: recipe)
        cell.backgroundColor = UIColor(red: 255/255, green: 204/255, blue: 102/255, alpha: 1)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let selectedRecipe = recipes[indexPath.row]
            didSelectRecipe?(selectedRecipe)
            dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let recipeToDelete = recipes[indexPath.row]
            recipesManager.deleteSteakRecipe(with: recipeToDelete.ID)
            recipes.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }


}
