//
//  FavListViewController.swift
//  DVT_WeatherApp
//
//  Created by Priteshsingh Chandel on 06/02/20.
//  Copyright © 2020 Priteshsingh Chandel. All rights reserved.
//

import UIKit

class FavListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, reloadVC {

    @IBOutlet var favListTableView: UITableView!
    
    var favName = [String]()
    var latArr = [String]()
    var lonArr = [String]()
    let color: UIColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialize()
        // Do any additional setup after loading the view.
    }
    func initialize(){
        favListTableView.register(UINib(nibName: "FavListTableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        
        self.view.backgroundColor = color
        let selectQuery = "select name,lat,lon from FavLocations"
        let selectAll = DBWrapper.sharedObj.selectAllTask(query:selectQuery)
        favName = (selectAll as? [String])!
        
        //newArray = DBWrapper.sharedObj.taskNameArray
        latArr = DBWrapper.sharedObj.latArr
        lonArr = DBWrapper.sharedObj.lonArr
        print("Favourites:\(favName)")
        favListTableView.delegate = self
        favListTableView.dataSource = self
        favListTableView.backgroundColor = UIColor.clear
    }
    
    enum JsonErrors:String,Error{
        
        case DataError = "Data not Found"
        case ConversionError = "Converson Failed"
    }
    
    func parseJSON(lat: Float, lon: Float)->String{
        let str =  "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=f99685d69f7533902651025577c79ca8"
        var weather = String()
        guard let url = URL(string: str) else
        {
            print("End Point Error")
            return ""
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            do{
                guard let data = data else
                {
                    throw JsonErrors.DataError
                }
                guard let outerDic = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:Any] else
                {
                    throw JsonErrors.ConversionError
                }
                 
                let weatherArray = outerDic["weather"] as! [[String: Any]]
                let dict0 = weatherArray[0]
                let main = dict0["main"] as! String
                print(main)
                DispatchQueue.main.async
                {
                    if main.contains("Cloud"){
                        weather = "CLOUDY"
                    }
                    else if main.contains("Rain"){
                        weather = "RAINY"
                    }
                    else{
                        weather = "SUNNY"
                    }
                }
               
            }
            catch let error as JsonErrors
            {
                print(error.rawValue)
            }
            catch let error as NSError
            {
                print(error.localizedDescription)
            }
            }.resume()
        return weather
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favName.count+1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FavListTableViewCell
        
        if indexPath.row == 0{
            cell.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0)
            cell.deleteBtn.isHidden = true
            cell.nameLbl.frame = CGRect(x: 0, y: 0, width: cell.frame.width, height: cell.frame.height)
            cell.nameLbl.translatesAutoresizingMaskIntoConstraints = true
            cell.nameLbl.text = "FAVOURITES"
            cell.nameLbl.textAlignment = .center
            cell.nameLbl.backgroundColor = UIColor.clear
            cell.nameLbl.textColor = UIColor.white
            cell.nameLbl.textAlignment = .center
            cell.nameLbl.font = cell.nameLbl.font.withSize(20)
        }
        else{
            cell.nameLbl.text = favName[indexPath.row-1]
            cell.nameLbl.textAlignment = .left
            cell.nameLbl.textColor = UIColor.white
            cell.deleteBtn.backgroundColor = UIColor.clear
            cell.deleteBtn.tag = indexPath.row-1
            let weather = parseJSON(lat: Float(latArr[indexPath.row-1])!, lon: Float(lonArr[indexPath.row-1])!)
            if weather == "CLOUDY"
            {
                cell.backgroundColor = cloudyColor
            }
            else if weather == "RAINY"{
                cell.backgroundColor = rainyColor
            }
            else
            {
                cell.backgroundColor = sunnyColor
            }
            
        }
        
        tableView.tableFooterView = UIView()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.performSegue(withIdentifier: "showFav", sender: indexPath.row)
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch: UITouch? = touches.first
        //location is relative to the current view
        // do something with the touched point
        if touch?.view != favListTableView {
            //performSegue(withIdentifier: "showFav", sender: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    func reload(){
        initialize()
        favListTableView.reloadData()
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol reloadVC {
    func reload();
}
