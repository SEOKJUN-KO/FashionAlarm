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
    
    var location: Location?
    var weatherInformation: WeatherInformation?
    var recommend: String?
    private let skView = SKView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubviewToBack(backgroundImg)
    }
    override func viewWillAppear(_ animated: Bool) {
        checkNeedChangeUI()
    }
}

extension AlarmResultViewController {
    
    private func saveAllInfo(weatherInformation: WeatherInformation, recommend: String) { // 함수 인자 너무 많음 -> 구조체로 전달
        guard let weather = weatherInformation.weather.first else { return }
        let userDefaults = UserDefaults.standard
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: Date())
        let data: [String:Any] = ["date": current_date_string, "weather": weather.description, "maxTmp": weatherInformation.temp.maxTemp, "minTmp": weatherInformation.temp.minTemp, "recommend": recommend]
        userDefaults.set( data, forKey: "FashionAllInfo" )
    }
    
    private func checkNeedChangeUI() {
        let userDefaults = UserDefaults.standard // 유틸로 빼서 구조화 -> 코드 간결화하기
        // 저장된 값이 없다. = 앱 사용이 처음이다.
        guard let data = userDefaults.object(forKey: "FashionAllInfo") as? [String: Any] else {
            getCoordinates()
            getCurrentWeather()
            return
        }
        guard let date = data["date"] as? String else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: Date())
        // 날짜가 다른 알람이 울려 정보 다시 얻어야함
        if( date != current_date_string ){
            getCoordinates()
            getCurrentWeather()
            return
        }
//        // 앱이 꺼졌다 켜졌을 때 -> weatherInformation & location이 지워짐
//        if( recommendClothesLabel.text == ""){
//            self.weatherInformation = WeatherInformation(
//            configureView()
//        }
    }
    
    
    private func getCoordinates() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "FashionAlarmCoordinates") as? [String: Double] else {
            print("위치 설정 필요")
            return }
        guard let lat = data["latitude"] else { return }
        guard let lon = data["longitude"] else { return }
        guard let address = userDefaults.object(forKey: "FashionAlarmAddress") as? String else { return }
        location = Location(address: address, latitude: lat, longitude: lon)
    }
    
    // 날씨 정보 받아오는 함수
    func getCurrentWeather() {
        guard let location = self.location else { return }
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=\(location.latitude)&lon=\(location.longitude)&appid=ff922c126429116c4fc0db7be1ee99af&lang=kr") else { return }
        //url 데이터 요청하는 부분은 rest api call 구조화 후 간결화 코드 공부하기
        let session = URLSession(configuration: .default)
        // url로 data 요청
        session.dataTask(with: url) { [weak self] data, response, error in // weak self 순환 참조 문제 해결
            guard let self = self else { return }
            let successRange = (200..<300)  // 200에서 299까지 값을 갖을 수 있음
            // data를 받아오고, error가 없을 때 계속 진행
            guard let data = data, error == nil else { return }
            let decoder = JSONDecoder() // json 객체에서 Data 유형의 instance로 decoding하는 객체
            if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {// 응답이 성공일
                guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return } // data를 WeatherInformation형태로 decoding
                DispatchQueue.main.async { // main thread에서 동작
                    self.recommend = self.recommendClothes( degree: (weatherInformation.temp.minTemp - 273.15 + weatherInformation.temp.maxTemp - 273.15)/2 )
                    self.weatherInformation = weatherInformation
                    self.saveAllInfo(weatherInformation: weatherInformation, recommend: self.recommend!)
                    self.configureView()
                }
            }
            else {
                guard let errorMesaage = try? decoder.decode(ErrorMessage.self, from: data) else { return } // 에러 메세지
                DispatchQueue.main.async { // main thread에서 동작
                    self.showAlert(message: errorMesaage.message)
                }
            }
        }.resume() // 작업 실행
    }
    
    func configureView() {
        guard let weather = self.weatherInformation?.weather.first else { return }
        weatherStackView.isHidden = false
        
        self.cityNameLabel.text =  self.location!.address
        
        chooseImgFromWeather(weather: weather.description)
        if(weather.description.contains("비") || weather.description.contains("눈")){
            setupUI()
        }
        else if(self.view.subviews.contains(skView)){
            skView.removeFromSuperview()
        }
        self.weatherDescriptionLabel.text = weather.description // 현재 날씨 라벨에 정보 표시
        self.minTempLabel.text = "최저: \(Int(self.weatherInformation!.temp.minTemp - 273.15))℃" // 최저온도 섭씨온도 변환 후 라벨에 표시
        self.maxTempLabel.text = "최고: \(Int(self.weatherInformation!.temp.maxTemp - 273.15))℃" // 최고온도 섭씨온도 변환 후 라벨에 표시
        self.recommendClothesLabel.text = recommend
        
        if(weather.description.contains("비") || weather.description.contains("눈")){
            setupUI()
        }
        else if(self.view.subviews.contains(skView)){
            skView.removeFromSuperview()
        }
        chooseImgFromWeather(weather: weather.description)
    }
    
    func showAlert(message: String) { // 에러시 alert 하는 함수
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func recommendClothes(degree: Double) -> String { // enum 처리 -> enum 공부하기 || 질문 = 범위로 return 값을 정하는데 어떻게 enum으로?
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
        if( self.view.subviews.contains(skView) ){
            return
        }
        view.addSubview(skView) // 만약 부모를 지우면 -> 자식들도 지워짐: 메모리 수준
        skView.translatesAutoresizingMaskIntoConstraints = false
        skView.backgroundColor = .clear
        let top = skView.topAnchor.constraint(equalTo: view.topAnchor, constant:  0)
        let leading = skView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0)
        let trailing = skView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
        let bottom = skView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        NSLayoutConstraint.activate([top, leading, trailing, bottom])
        
        initSpriteKitScene()
    }
    
    private func initSpriteKitScene() {
        let spriteKitScene = WeatherAnimationScene(size: CGSize(width: 1080, height: 1920)) // 숫자를 -> 변수로 => 여러 곳에서 사용된다면 변수를 수정하는 것으로 전체를 수정하는 효과
        spriteKitScene.scaleMode = .aspectFill
        spriteKitScene.backgroundColor = .clear // 이래야 뒤에 viewcontroller가 보임
        skView.presentScene(spriteKitScene)
    }
    
    private func chooseImgFromWeather(weather: String){ // 중복처리
        
        if(weather.contains("맑음")){
            backgroundImg.image = UIImage(named: "맑음.jpeg")!
        }
        else if(weather.contains("구름")){
            backgroundImg.image = UIImage(named: "구름.jpeg")!
        }
        else if(weather.contains("비")){
            backgroundImg.image = UIImage(named: "비.jpeg")!
        }
        else if(weather.contains("눈")){
            backgroundImg.image = UIImage(named: "눈.jpeg")!
        }
    }
}

