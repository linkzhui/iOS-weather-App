//
//  CitySlideViewController.swift
//  Lab3_Weather
//
//  Created by Jerry Lee on 12/8/17.
//  Copyright © 2017 Jerry Lee. All rights reserved.
//

import UIKit


class CitySlideViewController: UIViewController, UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource {

    //var cityWeatherDataList : [WeatherDataModel]?
    var slideviewIndex: Int = 0
    lazy var listCount = cityDataDict.count
    lazy var tableViewList = [UITableView]()
    lazy var cellList = [UITableViewCell]()
    var weatherList = [Int: [String]]()
    
    @IBOutlet weak var dynamicScrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //print(scrollView.contentOffset)
        pageControl.currentPage = Int(scrollView.contentOffset.x / CGFloat(375))
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        //receive notification from settings
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)

        // Do any additional setup after loading the view.

        for i in 0...listCount-1 {
            
            let cellTemp = UITableViewCell()
            let tableTemp = UITableView()
            cellList.insert(cellTemp, at: i)
            tableViewList.insert(tableTemp, at: i)
        }
        
        for eachView in tableViewList{
            eachView.delegate = self
            eachView.dataSource = self
        }
        pageControl.numberOfPages = listCount
        loadDataToStringList()
        dynamicScroll()
        initCustomTableView()
    }
    
    @objc func loadList(){
        //load data here
        for i in tableViewList{
            i.reloadData()
        }
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2 + 9 + 5  //返回TableView的Cell数量，可以动态设置；
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = UITableViewCell()
        
        var i = 0
        for tableItem in tableViewList {
            if tableView === tableItem {
                cellList[i] = tableItem.dequeueReusableCell(withIdentifier: "cell\(i)", for: indexPath as IndexPath)
                cellList[i].textLabel!.text = weatherList[i]![indexPath.row]
                cell = cellList[i]
            } else {
                i += 1
            }
        }
        return cell
        
    }
    func loadDataToStringList(){

        
        for i in 0...listCount-1{
            var weatherArray = [String]()
            let index = cityIndexDictionary[i]!
            
            weatherArray.append("\(cityDataDict[index]!.cityName)  \(cityDataDict[index]!.dayAndTime)")
            weatherArray.append("One Day Forecast Every Three Hours")
            var curTemp = Double()
            var curWeather = String()
            for j in [0,1,2,3,4,5,6,7]{
                curWeather = cityDataDict[index]!.oneDayWeather[j]
                curTemp = cityDataDict[index]!.oneDayTemp[j]
                
                if(Celcius){
                    weatherArray.append("\((j+1)*3) hours:  \(curWeather)  \(curTemp)°C")
                }else{
                    curTemp = changeTempToF(curTemp)
                    curTemp = Double(round(100*curTemp)/100)
                    weatherArray.append("\((j+1)*3) hours:  \(curWeather)  \(curTemp)°F")
                }
                
            }
            weatherArray.append("Future Four Days Forecast")
            var fourdaysTempHigh = Double()
            var fourdaysTempLow = Double()
            var fourdaysWeather = String()
            for k in 0...3{
                fourdaysWeather = cityDataDict[index]!.fourDayWeather[k]
                fourdaysTempLow = cityDataDict[index]!.fourDayTempLow[k]
                fourdaysTempHigh = cityDataDict[index]!.fourDayTempHigh[k]
                if(Celcius){
                    weatherArray.append("Day\(k+2): \(fourdaysWeather) Low: \(fourdaysTempLow)°C High: \(fourdaysTempHigh)°C")
                }else{
                    fourdaysTempLow = changeTempToF(fourdaysTempLow)
                    fourdaysTempLow = Double(round(100*fourdaysTempLow)/100)
                    fourdaysTempHigh = changeTempToF(fourdaysTempHigh)
                    fourdaysTempHigh = Double(round(100*fourdaysTempHigh)/100)

                    weatherArray.append("Day\(k+2): \(fourdaysWeather) Low: \(fourdaysTempLow)°F High: \(fourdaysTempHigh)°F")
                }
                
            }
            
            weatherList[i] = weatherArray
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        cell.backgroundColor = UIColor.clear
        cell.textLabel?.textColor = UIColor.white
        tableView.tableFooterView = UIView()
    }
    
    func dynamicScroll() {
        let tableW:CGFloat = self.dynamicScrollView.frame.size.width;
        let tableH:CGFloat = self.dynamicScrollView.frame.size.height;
        let tableY:CGFloat = 0;
        let totalCount: NSInteger = listCount;//只有三列；
        
        var i = 0
        for eachView in tableViewList{
            eachView.frame = CGRect(CGFloat(i) * tableW, tableY, tableW, tableH);
            i += 1
            dynamicScrollView.addSubview(eachView)
        }

        let contentW:CGFloat = tableW * CGFloat(totalCount);//这个表示整个ScrollView的长度；
        dynamicScrollView.contentSize = CGSize(contentW, 0);
        dynamicScrollView.isPagingEnabled = true;
        dynamicScrollView.delegate = self;
        let startpixel = Int(slideviewIndex*375)
        //var offsetPoint = CGPoint(CGFloat(startpixel), 0)
        dynamicScrollView.contentOffset = CGPoint(CGFloat(startpixel),0);
        
    }
    
    func  initCustomTableView(){    //初始化动态信息中的TableView
        var i = 0
        for eachView in tableViewList{
            eachView.register(UITableViewCell.self, forCellReuseIdentifier:"cell\(i)")
            i += 1
        }

    }
    
    func changeTempToF(_ tempInC: Double)-> Double {
        let tempInF = tempInC * 1.8 + 32
        return tempInF
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension CGRect{
    init(_ x:CGFloat,_ y:CGFloat,_ width:CGFloat,_ height:CGFloat) {
        self.init(x:x,y:y,width:width,height:height)
    }
    
}
extension CGSize{
    init(_ width:CGFloat,_ height:CGFloat) {
        self.init(width:width,height:height)
    }
}
extension CGPoint{
    init(_ x:CGFloat,_ y:CGFloat) {
        self.init(x:x,y:y)
    }
}
