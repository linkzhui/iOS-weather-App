//
//  ViewController.swift
//  Lab3_Weather
//
//  Created by Jerry Lee on 12/4/17.
//  Copyright © 2017 Jerry Lee. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import CoreLocation
import GooglePlacesSearchController

var cityDataDict = [String : WeatherDataModel]()
var cityIndexDictionary = [Int : String]()
var Celcius = true

class CityListViewController: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let WEATHER_FORECAST_URL = "http://api.openweathermap.org/data/2.5/forecast"
    let APPID = "824c7270cebd93216f6a414bc2bcfd9a"
    let GoogleMapsAPIServerKey = "AIzaSyBtE9NgcQCVYBxLcK0O_vZkYBwF4Kk0TnE"
    let LOCALTIME_URL = "http://api.timezonedb.com/v2/get-time-zone"
    let TIME_APP_ID = "FTOJTD92U9EW"
    
    let locationManager = CLLocationManager()
    
    
    //variable
    var googleSearchController: GooglePlacesSearchController!
    //var city : String = ""
    //var cityList : [String] = ["San Jose"]
    //var cityWeatherDataList = [WeatherDataModel]()
    
    @IBOutlet weak var cityListTableView: UITableView!

    
    //MARK: func prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CityCelltoSlideView" {
            var selectedRow = self.cityListTableView.indexPathForSelectedRow
            let destinationVC = segue.destination as! CitySlideViewController
            destinationVC.slideviewIndex = selectedRow!.row
        }
    }
    
    //MARK: Google place search auto complete: the search button connect to here and perform action
    @IBAction func searchAddress(_ sender: UIBarButtonItem) {
        //if you set placetype to geocode, it will return city names only!
        let controller = GooglePlacesSearchController ( apiKey: GoogleMapsAPIServerKey, placeType: PlaceType.cities)
        
        controller.didSelectGooglePlace { (place) -> Void in
            print(place.description)
            print(place.name)
            //Dismiss Search
            controller.isActive = false
            
            let latitude = String(place.coordinate.latitude)
            let longitude = String(place.coordinate.longitude)
            let params : [String:String] = ["lat": latitude, "lon": longitude, "units": "metric", "appid": self.APPID]
            let timeparams : [String : String] = ["key":self.TIME_APP_ID, "format": "json", "by" : "position", "lat": latitude, "lng": longitude]
            self.getWeatherData(parameters: params, timeParam: timeparams)
            self.cityListTableView.reloadData()
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        //ask permission for location and update location
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()

        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    @objc func loadList(){
        //load data here
        cityListTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: Networking - Get data with HTTP from OpenWeatherMap API
    /*************************************************/
    func getWeatherData(parameters : [String : String], timeParam: [String : String]) {
        var cityName : String = ""
        let myGroup = DispatchGroup()
        let myGroup2 = DispatchGroup()
        
        myGroup.enter()
        //Get current weather data
        Alamofire.request(self.WEATHER_URL, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Get Weather Data Successful")
                let weatherJSON : JSON = JSON(response.result.value!)
                cityName = weatherJSON["name"].stringValue
                print(cityName)
                self.updateWeatherDataFromJson(json: weatherJSON, cityName: cityName)
                print("Leave group")
                myGroup.leave()
            } else {
                print("Error \(String(describing: response.result.error))")
                print("Weather Connection Problem")
            }
        }
        myGroup2.enter()
        myGroup.notify(queue: .main){
        //get 5 days forecast data
        print("get into second")
            
        Alamofire.request(self.WEATHER_FORECAST_URL, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Get Forecast Data Successful")
                print(cityName)
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateForecastDataFromJson(json: weatherJSON, cityName: cityName)
                print("leave two")
                myGroup2.leave()
            } else {
                print("Error \(String(describing: response.result.error))")
                print ("Forecast Connection Problem")
            }
        }
        }
        myGroup2.notify(queue: .main){
            print("enter get time")
        //TODO: get time of the selected city
            
            Alamofire.request(self.LOCALTIME_URL, method: .get, parameters: timeParam).responseJSON {
            response in
            if response.result.isSuccess {
                print("Get timezonedb successful")
                let localtimeData : JSON = JSON(response.result.value!)
                print(cityName)
                self.updateTimeDataFromJson(json: localtimeData, cityname: cityName)
                
            } else {
                print("Error \(String(describing: response.result.error))")
                //self.cityLabel.text = "Connection Issues"
            }
        }
        }
    }
    //MARK: JSON Parsing
    /***********************************************/
    func updateWeatherDataFromJson (json: JSON, cityName: String){
        if let temp = json["main"]["temp"].double {
            let dataModel : WeatherDataModel
            
            if cityDataDict[cityName] == nil {
                dataModel = WeatherDataModel()
                dataModel.cityName = cityName
                cityIndexDictionary[cityIndexDictionary.count] = cityName
            } else {
                dataModel = cityDataDict[cityName]!
            }
            
            dataModel.currentTemp = temp
            dataModel.currentWeather = json["weather"][0]["main"].stringValue
            dataModel.condition = json["weather"][0]["id"].intValue
            dataModel.weatherIconName = dataModel.updateWeatherIcon()
            cityDataDict[cityName] = dataModel
            print("Update current weather successful")
        } else {
            print ("update current weather problem")
        }
    }
    
    func updateForecastDataFromJson (json: JSON, cityName: String){
        
        if json["cod"].intValue == 200 {
            
            if let dataModel = cityDataDict[cityName] {
                
                // update oneday forcast
                for index in 0...7 {
                    dataModel.oneDayTemp[index] = json["list"][index]["main"]["temp"].double!
                    dataModel.oneDayWeather[index] = json["list"][index]["weather"][0]["main"].stringValue
                }
                // update four day forcast
                var tempArray = Array(repeating: 0.0, count: 8)
                for index in 8...15 {
                    tempArray[index - 8] = json["list"][index]["main"]["temp"].double!
                    dataModel.fourDayWeather[0] = json["list"][index]["weather"][0]["main"].stringValue
                }
                var maxTemp = tempArray.max()
                var minTemp = tempArray.min()
                dataModel.fourDayTempHigh[0] = maxTemp!
                dataModel.fourDayTempLow[0] = minTemp!
                
                
                for index in 16...23 {
                    tempArray[index - 16] = json["list"][index]["main"]["temp"].double!
                    dataModel.fourDayWeather[1] = json["list"][index]["weather"][0]["main"].stringValue
                }
                maxTemp = tempArray.max()
                minTemp = tempArray.min()
                dataModel.fourDayTempHigh[1] = maxTemp!
                dataModel.fourDayTempLow[1] = minTemp!
                
                for index in 24...31 {
                    tempArray[index - 24] = json["list"][index]["main"]["temp"].double!
                    dataModel.fourDayWeather[2] = json["list"][index]["weather"][0]["main"].stringValue
                }
                maxTemp = tempArray.max()
                minTemp = tempArray.min()
                dataModel.fourDayTempHigh[2] = maxTemp!
                dataModel.fourDayTempLow[2] = minTemp!
                
                tempArray = Array(repeating: 0.0, count: 4)
                for index in 32...35 {
                    tempArray[index - 32] = json["list"][index]["main"]["temp"].double!
                    dataModel.fourDayWeather[3] = json["list"][index]["weather"][0]["main"].stringValue
                }
                maxTemp = tempArray.max()
                minTemp = tempArray.min()
                dataModel.fourDayTempHigh[3] = maxTemp!
                dataModel.fourDayTempLow[3] = minTemp!
                //update weather data
                cityDataDict[cityName] = dataModel
                print("update forecast successful")
            } else {
                print("update forecast error")
            }
            
            /*
             let weatherDataModel = WeatherDataModel()
             weatherDataModel.currentTemp = Int(temp - 273.15)
             weatherDataModel.cityName = json["name"].stringValue
             weatherDataModel.condition = json["weather"][0]["id"].intValue
             weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: weatherDataModel.condition)
             cityList.append(weatherDataModel.cityName)
             cityWeatherDataList.append(weatherDataModel)
             */
            
            cityListTableView.reloadData()
            print("Update Forecast Data successful")
            //cityNameLabel.text = weatherDataModel.cityName
            //cityTempLabel.text = "\(weatherDataModel.currentTemp)°"
            //weatherIcon.image = UIImage(named : weatherDataModel.weatherIconName)
            
        } else {
            print ("Update Forecast Weather Problem")
        }
    }
    
    // MARK: get local time from Timezonedb API
    
    func updateTimeDataFromJson(json : JSON, cityname: String) {
        //let formatedtimemodel = FormatedTimeModel()
        if let formatedtime = json["formatted"].string {
        print(" formatedtime: \(formatedtime)")
        // "formatted":"2016-02-02 21:03:11"
        let formatedlocaltime = localtimeconvertDateFormater(formatedtime)
        let formateddayanddate = dayandDateconvertDateFormater(formatedtime)
        
        let cityExists = cityDataDict[cityname] != nil
        if(!cityExists){
            let datamodel = WeatherDataModel()
            cityDataDict[cityname] = datamodel
        }
        
        cityDataDict[cityname]!.localtime = formatedlocaltime
        cityDataDict[cityname]!.dayAndTime = formateddayanddate
        print("")
        } else {
            print("update time problem")
        }
        
        cityListTableView.reloadData()
        //CityTimeModelList.append(formatedtimemodel)
        
        
    }
    func localtimeconvertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: date!)
        
    }
    
    func dayandDateconvertDateFormater(_ date: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dateFormatter.date(from: date)
        // desired format: Thursday   Oct   18
        //EEEE for weekday
        //MMMM for month name
        dateFormatter.dateFormat = "EEEE MMMM dd"
        return dateFormatter.string(from: date!)
        
    }
    
    
    
    //MARK: UI update
    func setLabels(weatherData: NSData) {
        
    }
    
    
    
    //MARK: Location manager
    //didUpdateLocations method
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations[locations.count - 1]
        if location.horizontalAccuracy > 0 {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            print("lon =  \(location.coordinate.longitude), lat = \(location.coordinate.latitude)")
            let latitude = String(location.coordinate.latitude)
            let longitude = String(location.coordinate.longitude)
            let params : [String:String] = ["lat": latitude, "lon": longitude, "units": "metric", "appid": APPID ]
            let timeparams : [String : String] = ["key":TIME_APP_ID, "format": "json", "by" : "position", "lat": latitude, "lng": longitude]
            getWeatherData(parameters: params, timeParam: timeparams)
        }
    }
    //didFailWithError method
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        //cityNameLabel.text = "Location Unavailable"
        
    }
    
    
    //MARK: Change View
    
    //MARK: Table View Controller
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cityDataDict.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityListTableViewCell", for: indexPath) as! CityListTableViewCell
        
        let index = cityIndexDictionary[indexPath.row]
        cell.cityNameLabel.text = cityDataDict[index!]!.cityName
        print(cityDataDict[index!]!.cityName)
        if(Celcius){
            cell.cityTempLabel.text = "\(cityDataDict[index!]!.currentTemp)°C"
        }else{
            var tempinf = changeTempToF(cityDataDict[index!]!.currentTemp)
            tempinf = Double(round(100*tempinf)/100)
            cell.cityTempLabel.text = "\(tempinf)°F"
        }
        
        
        cell.cityWeaterLabel.text = cityDataDict[index!]!.currentWeather
        cell.weatherIcon.image = UIImage(named : cityDataDict[index!]!.weatherIconName)
        cell.timeLabel.text = cityDataDict[index!]!.localtime
        print(cityDataDict[index!]!.localtime)
        return cell
    
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.backgroundColor = .clear
        cell.backgroundColor = UIColor.clear
        tableView.tableFooterView = UIView()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            // handle delete (by removing the data from your array and updating the tableview)
            cityDataDict.removeValue(forKey: cityIndexDictionary[indexPath.row]!)
            let listNumber = cityIndexDictionary.count - 1
            for i in indexPath.row...listNumber {
                cityIndexDictionary[i] = cityIndexDictionary[i+1]
            }
            cityIndexDictionary.removeValue(forKey: listNumber)
            print("This is row \(cityIndexDictionary)")
            cityListTableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    //should do something if someone selected the row
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let index = cityIndexDictionary[indexPath.row]
        let toprint = cityDataDict[index!]!.cityName
        print("This is row \(toprint)")
    }
    
    
    func changeTempToF(_ tempInC: Double)-> Double {
        let tempInF = tempInC * 1.8 + 32
        return tempInF
    }
    

}

