//
//  locationModel.swift
//  Lab6
//
//  Created by Mitchie Steddom on 10/27/24.
//
import SwiftUI
import Foundation
import CoreLocation
import MapKit

class locationModel: ObservableObject {
    // Create model for location records
    @Published var locationModel : [UUID:locationRecord] = [UUID(): locationRecord(cityName: "Phoenix", cityDescription: "Great place", cityImage: "phx")]
    // Create array to keep track of order
    var locationModelOrder : [UUID] = []
    
    // Variables to get coordingates
    
    
    func addRecord (cityName: String, cityDescription: String, cityImage: String){
        // Create record object
        let locRecord = locationRecord(cityName: cityName, cityDescription: cityDescription, cityImage: cityImage)
        // Add record to location
        locationModel[locRecord.id] = locRecord
    }
    
    // Function to delete a location
    func deleteLocation(locDelete: String) {
        // Search movie record by movie name and removed it via key
        if let locDelete = locationModel.first(where: { $0.value.cityName == locDelete })?.key {
            locationModel.removeValue(forKey: locDelete)
        }
    }
    
   
    
    
}
