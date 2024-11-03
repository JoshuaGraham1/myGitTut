//
//  locationRecord.swift
//  Lab6
//
//  Created by Mitchie Steddom on 10/27/24.
//
import SwiftUI
import Foundation

// Struct containg variables to be stored of cities
struct locationRecord: Identifiable {
    var id = UUID()
    var cityName = String ()
    var cityDescription = String()
    var cityImage = String()
}
