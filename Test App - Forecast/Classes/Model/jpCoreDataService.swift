//
//  jpCoreDataService.swift
//  Test App - Forecast
//
//  Created by Jakub on 14.02.17.
//  Copyright © 2017 Ponikelský Jakub. All rights reserved.
//

import CoreData

class jpCoreDataService: NSObject {
    
    /// Singleton instance of jpWeatherService
    static let instance = jpCoreDataService()
    
    /// Private constructor
    private override init(){
        super.init();
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.cadiridris.coreDataTemplate" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "Test_App___Forecast", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Test_App___Forecast.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    public func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}

// MARK: - jpWeatherService support helpers

extension jpCoreDataService {
    /**
     Delete all entities of given type
     - Parameter entityName: Entity name
     */
    fileprivate func deleteEntityData(entityName: String) throws -> Void {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchRequest.returnsObjectsAsFaults = false
        
        let results = try self.managedObjectContext.fetch(fetchRequest)
        for managedObject in results
        {
            let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
            self.managedObjectContext.delete(managedObjectData)
        }
    }
}

// MARK: - jpWeatherServiceWeekDataStore support

extension jpCoreDataService: jpWeatherServiceWeekDataStore {
    /**
     Delete all entities of forecast
     */
    internal func deleteAllData() throws -> Void {
        try self.deleteEntityData(entityName: "ForecastCity")
        try self.deleteEntityData(entityName: "ForecastTimemark")
    }
    
    /**
     Save data about city in CoreData
     - Parameter appName: City name in app
     - Parameter name: Name at OWM
     - Parameter country: Country
     - Parameter id: City id
     - Parameter latitude: Position latitude
     - Parameter longitude: Position longitude
     */
    internal func saveLocationData(appName: String, name: String, country: String, id: Int, latitude: Double, longitude: Double) throws -> Void {
        let entity =
            NSEntityDescription.entity(forEntityName: "ForecastCity",
                                       in: self.managedObjectContext)!
        let coreDataCity = NSManagedObject(entity: entity,
                                           insertInto: self.managedObjectContext)
        coreDataCity.setValue(appName, forKey: "appName")
        coreDataCity.setValue(country, forKey: "country")
        coreDataCity.setValue(id, forKey: "id")
        coreDataCity.setValue(latitude, forKey: "latitude")
        coreDataCity.setValue(longitude, forKey: "longitude")
        coreDataCity.setValue(name, forKey: "name")
    }

    /**
     Save data about city forecast in CoreData
     - Parameter datetime: Date time as number of seconds
     - Parameter temperature: Temperature
     - Parameter wearherDesc: Short weather decs
     - Parameter wearherIcon: Icon of weather
     - Parameter wearherText: Long weather text
     */
    internal func saveWeatherDataForTime(datetime: Int, temperature: Double, wearherDesc: String, wearherIcon: String, wearherText: String) throws -> Void {
        let entity =
            NSEntityDescription.entity(forEntityName: "ForecastTimemark",
                                       in: self.managedObjectContext)!
        let coreDataTimemark = NSManagedObject(entity: entity,
                                           insertInto: self.managedObjectContext)
        coreDataTimemark.setValue(datetime, forKey: "datetime")
        coreDataTimemark.setValue(temperature, forKey: "temperature")
        coreDataTimemark.setValue(wearherDesc, forKey: "weather_desc")
        coreDataTimemark.setValue(wearherIcon, forKey: "weather_icon")
        coreDataTimemark.setValue(wearherText, forKey: "weather_text")
    }
}
