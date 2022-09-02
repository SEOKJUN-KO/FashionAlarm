//
//  AlarmResultViewController.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/15.
//

import UIKit
import SpriteKit

class AlarmResultViewController: UIViewController {
    
    @IBOutlet weak var backgroundImg: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var weatherStackView: UIStackView!
    @IBOutlet weak var recommendClothesLabel: UILabel!
    
    var latitude: Double?
    var longitude: Double?
    private let skView = SKView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubviewToBack(backgroundImg)
        setupUI()
        initSpriteKitScene()
    }
    override func viewWillAppear(_ animated: Bool) {
        loadAllInfo()
    }
}

extension AlarmResultViewController {
    
    private func saveAllInfo(weather: String , maxTmp: Int, minTmp: Int, recommend: String) {
        let userDefaults = UserDefaults.standard
        //    날짜, 날씨, 최대 기온, 최소 기온, 추천
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: Date())
        let data: [String:Any] = ["date": current_date_string, "weather": weather, "maxTmp": maxTmp, "minTmp": minTmp, "recommend": recommend]
        userDefaults.set( data, forKey: "FashionAllInfo" )
    }
    
    private func loadAllInfo() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "FashionAllInfo") as? [String: Any] else {
            getCoordinates()
            getCurrentWeather()
            return
        } // 저장된 값이 없다. = 앱 사용이 처음이다.
        guard let date = data["date"] as? String else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: Date())
        if( date != current_date_string ){ // 날짜가 다른 알람이 울려 정보 다시 얻어야함
            getCoordinates()
            getCurrentWeather()
            return
        }
        guard let weather = data["weather"] as? String else { return }
        chooseImgFromWeather(weather: weather)
        guard let maxTmp = data["maxTmp"] as? Int else { return }
        guard let minTmp = data["minTmp"] as? Int else { return }
        guard let recommend = data["recommend"] as? String else { return }
        weatherStackView.isHidden = false
        weatherDescriptionLabel.text = weather // 현재 날씨 라벨에 정보 표시
        minTempLabel.text = "최저: \(maxTmp)℃" // 최저온도 섭씨온도 변환 후 라벨에 표시
        maxTempLabel.text = "최고: \(minTmp)℃" // 최고온도 섭씨온도 변환 후 라벨에 표시
        recommendClothesLabel.text = recommend
    }
    
    
    private func getCoordinates() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "FashionAlarmCoordinates") as? [String: Double] else { return }
        guard let lat = data["latitude"] else { return }
        guard let lon = data["longitude"] else { return }
        latitude = lat
        longitude = lon
        guard let address = userDefaults.object(forKey: "FashionAlarmAddress") as? String else { return }
        self.cityNameLabel.text =  address
    }
    
    // 날씨 정보 받아오는 함수
    func getCurrentWeather() {
        guard let lat = latitude else { return }
        guard let lon = longitude else { return }
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=ff922c126429116c4fc0db7be1ee99af&lang=kr") else { return }
        
        let session = URLSession(configuration: .default)
        // url로 data 요청
        session.dataTask(with: url) { [weak self] data, response, error in // weak self 순환 참조 문제 해결
            let successRange = (200..<300)  // 200에서 299까지 값을 갖을 수 있음
            // data를 받아오고, error가 없을 때 계속 진행
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder() // json 객체에서 Data 유형의 instance로 decoding하는 객체
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {// 응답이 성공일
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return } // data를 WeatherInformation형태로 decoding
                
                DispatchQueue.main.async { // main thread에서 동작
                    self?.weatherStackView.isHidden = false // 날씨 정보를 표시 해주는 스택뷰 보이게
                    self?.configureView(weatherInformation: weatherInformation) // 타이틀에 정보 표시
                }
            }
            else {
                guard let errorMesaage = try? decoder.decode(ErrorMessage.self, from: data) else { return } // 에러 메세지
                DispatchQueue.main.async { // main thread에서 동작
                    self?.showAlert(message: errorMesaage.message)
                }
            }
        }.resume() // 작업 실행
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        guard let weather = weatherInformation.weather.first else { return }
        chooseImgFromWeather(weather: weather.description)
        self.weatherDescriptionLabel.text = weather.description // 현재 날씨 라벨에 정보 표시
//        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃" // 섭씨온도 변환
        self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))℃" // 최저온도 섭씨온도 변환 후 라벨에 표시
        self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))℃" // 최고온도 섭씨온도 변환 후 라벨에 표시
        let recommend = recommendClothes( degree: (weatherInformation.temp.minTemp - 273.15 + weatherInformation.temp.maxTemp - 273.15)/2 )
        self.recommendClothesLabel.text = recommend
        saveAllInfo(weather: weather.description, maxTmp: Int(weatherInformation.temp.minTemp - 273.15), minTmp: Int(weatherInformation.temp.maxTemp - 273.15), recommend: recommend)
    }
    
    func showAlert(message: String) { // 에러시 alert 하는 함수
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func recommendClothes(degree: Double) -> String {
        if( degree >= 28 ){ return "민소매, 반팔, 반바지, 짧은 치마, 린넨 옷"
        } else if( degree >= 23 ) { return "반팔, 얇은 셔츠, 반바지, 면바지"
        } else if( degree >= 20 ) { return "블라우스, 긴팔 티, 면바지, 슬랙스"
        } else if( degree >= 17 ) { return "얇은 가디건, 니트, 맨투맨, 후드, 긴 바지"
        } else if( degree >= 12 ) { return "자켓, 가디건, 청자켓, 니트, 스타킹, 기모바지"
        } else if( degree >= 9 ) { return "트렌치 코트, 야상, 점퍼, 스타킹, 기모바지"
        } else if ( degree >= 5 ) { return "울 코트, 히트택, 가죽 옷, 기모"
        } else { return "패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리" }
    }
    
    private func setupUI(){
        view.addSubview(skView)
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.backgroundColor = .clear
        let top = skView.topAnchor.constraint(equalTo: view.topAnchor, constant:  0)
        let leading = skView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        let trailing = skView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        let bottom = skView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        NSLayoutConstraint.activate([top, leading, trailing, bottom])
    }
    
    private func initSpriteKitScene() {
        let snowScene = SnowScene(size: CGSize(width: 1080, height: 1920))
        snowScene.scaleMode = .aspectFill
        snowScene.backgroundColor = .clear // 이래야 뒤에 viewcontroller가 보임
        
        skView.presentScene(snowScene)
    }
    
    private func chooseImgFromWeather(weather: String){
        if(weather.contains("맑음")){
            backgroundImg.image = UIImage(named: "맑음.jpeg")!
        }
        else if(weather.contains("구름")){
            backgroundImg.image = UIImage(named: "구름.jpeg")!
        }
    }
}

