//
//  WeatherDataModel.swift
//  Lab3_Weather
//
//  Created by Jerry Lee on 12/6/17.
//  Copyright © 2017 Jerry Lee. All rights reserved.
//

import Foundation

class WeatherDataModel {
    
    var cityName : String = ""
    //cur weather
    var currentTemp : Double = 0
    var currentWeather : String = ""
    var condition : Int = 0
    var weatherIconName : String = ""
    
    var localtime: String = ""
    var dayAndTime: String = ""
    
    //oneday forcast
    var oneDayTemp = Array(repeating: 0.0, count: 8)
    var oneDayWeather = Array(repeating: "", count: 8)
    
    //fourday forcast
    var fourDayTempHigh = Array(repeating: 0.0, count: 4)
    var fourDayTempLow = Array(repeating: 0.0, count: 4)
    var fourDayWeather = Array(repeating: "", count: 4)
    
    
    func updateWeatherIcon() -> String {
        
        switch (condition) {
            
        case 0...300 :
            return "tstorm1"
            
        case 301...500 :
            return "light_rain"
            
        case 501...600 :
            return "shower3"
            
        case 601...700 :
            return "snow4"
            
        case 701...771 :
            return "fog"
            
        case 772...799 :
            return "tstorm3"
            
        case 800 :
            return "sunny"
            
        case 801...804 :
            return "cloudy2"
            
        case 900...903, 905...1000  :
            return "tstorm3"
            
        case 903 :
            return "snow5"
            
        case 904 :
            return "sunny"
            
        default :
            return "dunno"
        }
        
    }
    
    
}
