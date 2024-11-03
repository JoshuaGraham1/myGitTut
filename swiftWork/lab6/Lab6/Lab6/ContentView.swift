//
//  ContentView.swift
//  Lab6
//
//  Created by Mitchie Steddom on 10/27/24.
//
import Foundation
import SwiftUI
import CoreLocation
import MapKit

// Struct for locationView
struct Location: Identifiable {
    let id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}


struct ContentView: View {
    // Create model
    @ObservedObject var locModel = locationModel()
    // Variables for user input
    @State var cName = String()
    @State var cDescription = String()
    @State var cImage = String()
    //@State var coordinate: CLLocationCoordinate2D
    // Variables for Insert/Delete views
    @State var toInsertView = false
    @State var toDeleteView = false
    @State var toDeleteCity = String()
    
    var body: some View {
        NavigationView {
            List {
                // Display all cities in list
                ForEach(locModel.locationModel.keys.sorted(), id: \.self) { id in
                    // Create object for each model
                    if let lModel = locModel.locationModel[id] {
                        // Navigation view which allows users to click and go to a detail view for specific location
                        NavigationLink(destination: detailLocationView(locName: lModel.cityName, locDescription: lModel.cityDescription, locImage: lModel.cityImage)){
                            // Stacks to organize information and display it
                            VStack(alignment: .leading){
                                HStack{
                                    Image(lModel.cityImage)
                                    .resizable()
                                        .frame(width: 50, height: 50)
                                    Text(lModel.cityName)
                                }
                                Spacer()
                                HStack{
                                    Text("Description: ")
                                    Text(lModel.cityDescription)
                                }
                                
                            }
                            .padding()
                        }
                    }
                }
                // Navigation bar section
            }.navigationBarTitleDisplayMode(.inline)
                .navigationTitle("Locations")
                .toolbar {
                    // Add button
                    ToolbarItem(placement: .navigationBarTrailing){
                        Button {
                            toInsertView = true
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                    // Delete button
                    ToolbarItem(placement: .navigationBarLeading){
                        Button {
                            toDeleteView = true
                        } label: {
                            Image(systemName: "trash")
                        }
                    }
                }   // Prompt when user wants to add a city
                .alert("Add City", isPresented: $toInsertView, actions: {
                    TextField("City name", text: $cName)
                        .textInputAutocapitalization(.never)
                    TextField("Name of city image", text: $cImage)
                        .textInputAutocapitalization(.never)
                    TextField("City description", text: $cDescription)
                        .textInputAutocapitalization(.never)
                    // Cancel button
                    Button("Cancel", role: .cancel, action: {
                        toInsertView = false
                    })
                    // Add button
                    Button("Add", action: {
                        locModel.addRecord(cityName: cName, cityDescription: cDescription, cityImage: cImage)
                        cName = ""
                        cDescription = ""
                        cImage = ""
                    })
                }, message: {
                    Text("Enter in city information")
                }
            )   // Prompt when user wants to delete a city
                .alert("Delete City", isPresented: $toDeleteView, actions: {
                    TextField("City name", text: $toDeleteCity)
                    // Cancel button
                    Button("Cancel", role: .cancel, action: {
                        toDeleteView = false
                    })
                    // Delete button
                    Button("Delete", action: {
                        locModel.deleteLocation(locDelete: toDeleteCity)
                        toDeleteCity = ""
                    })
                })
                    
        }
    }
}
// Detailed view of city. Will present a button a user can click to display the city they selected
struct detailLocationView: View {
    // Variables for city info
    var locName: String
    var locDescription: String
    var locImage: String
    var coordinate: CLLocationCoordinate2D?
    // Default coordinates
    @State private static var defaultLocation = CLLocationCoordinate2D(
        latitude: 33.4255,
        longitude: -111.9400
    )
    // Region variable. Set with default coordinates
    @State private var region = MKCoordinateRegion(
        center: defaultLocation,
        span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    // Markers dictionary, default to tempe location
    @State private var markers = [
        Location(name: "Tempe", coordinate: defaultLocation)
    ]
    // Search text variable
    @State private var searchText = ""
    // Appear variable for map
    @State private var showMap: Bool = false
    var body: some View {
        VStack {
            // When clicked, presents map and marker with place name
            Button("Show Location Information", action: {
                forwardGeocoding(cityName: locName)
                showMap.toggle()
            })
            if showMap {
                // Map variable
                Map(coordinateRegion: $region,
                    interactionModes: .all,
                    annotationItems: markers
                ){ location in
                    // Create a map annotation. Will display city name and a map marker (pin)
                    MapAnnotation(coordinate: location.coordinate) {
                        VStack {
                            // Display city name
                            Text(location.name)
                                .font(.caption)
                                .padding(5)
                                .background(Color.white)
                                .cornerRadius(5)
                            // Display pin image
                            Image(systemName: "mappin.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.red)
                        }
                    }
                }
                // Display latitude
                HStack {
                    Text("Latitude: ")
                    Text(String(region.center.latitude))

                }
                // Display longitude
                HStack {
                    Text("Longitude: ")
                    Text(String(region.center.longitude))
                }
                // Display text field for user search
                HStack {
                    TextField("Search nearby: ", text: $searchText)
                }
                // Search bar variable
                searchBar
            }
        }
    }
    // View contains button. When pressed, places related to search name will display on the map within the area of the city
    private var searchBar: some View {
        HStack {
            Button {
                // Create search request
                let searchRequest = MKLocalSearch.Request()
                searchRequest.naturalLanguageQuery = searchText
                searchRequest.region = region
                // Local search
                MKLocalSearch(request: searchRequest).start {response, error in
                    guard let response = response else {
                        print("Error")
                        return
                    }
                    region = response.boundingRegion
                    markers = response.mapItems.map { item in
                        // Location name and coordinate assingment for places
                        Location(
                            name: item.name ?? "",
                            coordinate: item.placemark.coordinate
                        )
                    }
                }
            } label: {
                Image(systemName: "location.circle")
            }
        }
    }
    // Function to get location of city name
    func forwardGeocoding(cityName: String)
    {
        // Geocoder object
        _ = CLGeocoder();
        // variable for city name
        let cityString = cityName
        CLGeocoder().geocodeAddressString(cityString, completionHandler:
                                            {(placemarks, error) in
            
            if error != nil {
                print("Geocode failed: \(error!.localizedDescription)")
            } else if placemarks!.count > 0 {
                let placemark = placemarks![0]
                let location = placemark.location
                let coords = location!.coordinate
                print(coords.latitude)
                print(coords.longitude)
                // Ajust variables to set location to city location
                DispatchQueue.main.async
                    {
                        region.center = coords
                        markers[0].name = placemark.locality!
                        markers[0].coordinate = coords
                    }
            }
        })
    }
}

#Preview {
    ContentView()
}
