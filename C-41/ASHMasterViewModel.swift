//
//  ASHMasterViewModel.swift
//  C-41
//
//  Created by Nicholas Sakaimbo on 12/13/16.
//  Copyright © 2016 Ash Furrow. All rights reserved.
//

import CoreData
import Foundation

class ASHMasterViewModel: RVMViewModel, NSFetchedResultsControllerDelegate {
 
    private func performFetch(with controller: NSFetchedResultsController<ASHRecipe>) {
        
        do {
            try controller.performFetch()
        }
        catch {
            fatalError("Unresolved error")
        }
    }
    
    lazy var fetchedResultsController: NSFetchedResultsController<ASHRecipe> = {
       
        guard let context = self.model as? NSManagedObjectContext else { fatalError() }
        
        let request = NSFetchRequest<ASHRecipe>(entityName: "ASHRecipe")
        request.fetchBatchSize = 20
        let nameSort = NSSortDescriptor(key: "name", ascending: true)
        let filmTypeSort = NSSortDescriptor(key: "filmType", ascending: false)
        let sortDescriptors = [filmTypeSort, nameSort]
        request.sortDescriptors = sortDescriptors
        
        let controller = NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "filmType", cacheName: "Master")
        controller.delegate = self
        
        return controller
    }()
    
    var updatedContentSignal: RACSubject!
    
    override init!(model: Any!) {
        super.init(model: model)
       
        let subject = RACSubject()
        subject.name = "ASHMasterViewModel updatedContentSignal"
        updatedContentSignal = subject
     
        _ = updatedContentSignal?.subscribeNext { [weak self] _ in
            if let controller = self?.fetchedResultsController {
                self?.performFetch(with: controller)
            }
        }
        
        self.performFetch(with: fetchedResultsController)
    }
    
    
    func numberOfSections() -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func deleteObjectAtIndexPath(_ indexPath: IndexPath) {
        
        let object = fetchedResultsController.object(at: indexPath)
        
        let context = fetchedResultsController.managedObjectContext
        context.delete(object)
        
        do {
            try context.save()
        }
        catch {
            fatalError( "Unresolved error. \(error.localizedDescription)")
        }
    }
    
    func numberOfItemsInSection(_ section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func titleForSection(_ section: Int) -> String? {
        
        guard let sectionInfo = fetchedResultsController.sections?[section],
        let objects = sectionInfo.objects,
        let representativeObject = objects.first as? ASHRecipe,
        let filmType = ASHRecipeFilmType(rawValue: UInt(representativeObject.filmType)) else {
            return nil
        }
       
        switch filmType {
        case .blackAndWhite:
            return NSLocalizedString("Black and White", comment: "Section header title")
            // Note how I kept the original/Commonwealth spelling of "Colour"
        case .colourNegative:
            return NSLocalizedString("Colour Negative", comment: "Section header title")
        case .colourPositive:
            return NSLocalizedString("Colour Postive", comment: "Section header title")
        }
    }
   
    private func recipeAtIndexPath(_ indexPath: IndexPath) -> ASHRecipe {
        return fetchedResultsController.object(at: indexPath)
    }
    
    func titleAtIndexPath(_ indexPath: IndexPath) -> String? {
        let recipe = recipeAtIndexPath(indexPath)
        //TODO: Is this a potential use case for nullability identifiers in the objective-c model?
        return recipe.name
    }
    
    func subtitleAtIndexPath(_ indexPath: IndexPath) -> String? {
        let recipe = recipeAtIndexPath(indexPath)
        //TODO: Is this a potential use case for nullability identifiers in the objective-c model?
        return recipe.blurb
    }
    
    func editViewModelForIndexPath(_ indexPath: IndexPath) -> ASHEditRecipeViewModel? {
        let model = recipeAtIndexPath(indexPath)
        let viewModel = ASHEditRecipeViewModel(model: model)
        return viewModel
    }
    
    func editViewModelForNewRecipe() -> ASHEditRecipeViewModel? {
        
        guard let context = model as? NSManagedObjectContext,
            let description = NSEntityDescription.entity(forEntityName: "ASHRecipe", in: context) else {
            return nil
        }
        
        let recipe = NSManagedObject(entity: description, insertInto: context)
        let viewModel = ASHEditRecipeViewModel(model: recipe)
        viewModel?.isInserting = true
        return viewModel
    }
    
    func detailViewModelForIndexPath(_ indexPath: IndexPath) -> ASHDetailViewModel? {
        let viewModel = ASHDetailViewModel(model: recipeAtIndexPath(indexPath))
        return viewModel
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        updatedContentSignal.sendNext(nil)
    }
}
