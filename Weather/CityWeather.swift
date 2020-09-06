//
//  CityWeather.swift
//  Weather
//
//  Created by Martin Kostelej on 02/09/2020.
//  Copyright © 2020 Martin Kostelej. All rights reserved.
//

import UIKit

class CityWeather{
    var name: String
    var description: String
    var main: String
    var temperature: Double
    var lon: Double
    var lat: Double
    var maxTemp: Double
    var minTemp: Double
    var country: String
    
    init(pName: String, pDescription: String, pTemperature: Double, pLon: Double, pLat: Double, pMaxTemp: Double, pMinTemp: Double, pCountry: String, pMain: String) {
        name = pName
        description = pDescription
        temperature = pTemperature
        lon = pLon
        lat = pLat
        maxTemp = pMaxTemp
        minTemp = pMinTemp
        country = pCountry
        main = pMain
    }

}
