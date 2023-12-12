//
//  Recipes.swift
//  PerfectSteak
//
//  Created by Dajun Xian on 4/24/23.
//

import Foundation
import CoreData

class Recipes {
    private let context = CoreDataStack.shared.persistentContainer.viewContext
    
    init() {
        createDefaultRecipeIfNeeded()
    }
    
    var steakRecipes: [SteakRecipe] {
        return fetchAllRecipes()
    }

    //Create a default recipe when there is no recipe.
    func createDefaultRecipeIfNeeded() {
        let defaultUUID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
        
        if fetchRecipe(with: defaultUUID) == nil {
            let defaultRecipe = SteakRecipe(ID: defaultUUID, thickness: 1.0, initialTemp: 60, ovenTemp: 350, desiredCenterTemp: 135)
            addSteakRecipe(defaultRecipe)
        }
    }
    
    //Get one recipe if there is no recipe
    func fetchRecipe(with uuid: UUID) -> SteakRecipe? {
        let fetchRequest: NSFetchRequest<CDSteakRecipe> = CDSteakRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first.map { SteakRecipe(cdSteakRecipe: $0) }
        } catch {
            print("Error fetching recipe: \(error)")
            return nil
        }
    }
    
    //Get all recipes
    func fetchAllRecipes() -> [SteakRecipe] {
        let fetchRequest: NSFetchRequest<CDSteakRecipe> = CDSteakRecipe.fetchRequest()
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.map { SteakRecipe(cdSteakRecipe: $0) }
        } catch {
            print("Error fetching recipes: \(error)")
            return []
        }
    }
    
    //Add one recipe
    func addSteakRecipe(_ recipe: SteakRecipe) {
        let cdSteakRecipe = CDSteakRecipe(context: context)
        cdSteakRecipe.id = recipe.ID
        cdSteakRecipe.thickness = recipe.thickness
        cdSteakRecipe.initialTemp = recipe.initialTemp
        cdSteakRecipe.ovenTemp = recipe.ovenTemp
        cdSteakRecipe.desiredCenterTemp = recipe.desiredCenterTemp
        
        CoreDataStack.shared.saveContext()
    }
    
    
    //Remove a recipe from the stack
    func deleteSteakRecipe(with uuid: UUID) {
        let fetchRequest: NSFetchRequest<CDSteakRecipe> = CDSteakRecipe.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)
        
        do {
            let results = try context.fetch(fetchRequest)
            
            if let recipeToDelete = results.first {
                context.delete(recipeToDelete)
                CoreDataStack.shared.saveContext()
            }
        } catch {
            print("Error fetching recipe to delete: \(error)")
        }
    }
}
