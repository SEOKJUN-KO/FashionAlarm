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
    var alarmResultUI: AlarmResultUI?
    private let skView = SKView()
    let storage = Storage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubviewToBack(backgroundImg)
    }
    override func viewWillAppear(_ animated: Bool) {
        checkNeedChangeUI()
    }
}

extension AlarmResultViewController {
    
    private func saveFashionAllInfo(alarmResultUI: AlarmResultUI) { // 함수 인자 너무 많음 -> 구조체로 전달
        guard let alarmResultUI = self.alarmResultUI else { return }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let current_date_string = formatter.string(from: Date())
        let data: [String:Any] = ["date": current_date_string, "weather": alarmResultUI.weather, "maxTmp": alarmResultUI.maxTmp, "minTmp": alarmResultUI.minTmp, "recommend": alarmResultUI.recommend]
        // Parsing 부분 구조화 하면 간결화 해짐. 해도 안해도 무관
        // Class로 Parsing으로 만들어
        storage.setAlarmResultUI(key: "FashionAllInfo", data: data)
    }
    
    private func checkNeedChangeUI() {
        guard let locationData = getCoordinates() else { return }
        // 저장된 값이 없다. = 앱 사용이 처음이다.
        guard let data = storage.getAlarmResultUI(key: "FashionAllInfo") else {
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
        // 앱이 꺼졌다 켜졌을 때 = 메모리에서 내려간 후 다시 올라 왔을 때 -> alarmResult & location이 지워짐
        if( recommendClothesLabel.text == ""){
            getCoordinates()
            alarmResultUI = AlarmResultUI(weather: data["weather"] as! String, maxTmp: data["maxTmp"] as! Double, minTmp: data["minTmp"] as! Double, recommend: data["recommend"] as! String)
            configureView()
        }
    }
    
    
    private func getCoordinates() -> Bool? {
        let address = storage.getAddress(key: "FashionAlarmAddress")
        if ( address == "" ) {
            let alert = UIAlertController(title: "위치를 설정하셔야합니다.", message: "", preferredStyle: .alert)
            let confirm = UIAlertAction(title: "확인", style: .default, handler: nil)
            alert.addAction(confirm)
            present(alert, animated: false) // is discouraged. 해결법 찾기
            return nil
        }
        let data = storage.getLocation(key: "FashionAlarmCoordinates")
        location = Location(address: address, latitude: data["latitude"]!, longitude: data["longitude"]!)
        return true
    }
    
    // 날씨 정보 받아오는 함수
    func getCurrentWeather() {
        let queryParam: [String: String] = ["lat": String(location!.latitude), "lon": String(location!.longitude), "appid": API.APP_ID, "lang": "kr"]
        do {
            URLSessionManager
                .shared
                .session
                .dataTask(with: try WeatherRouter(weatherRouterInit: .getWeather(query: queryParam)).asURLRequest()) { [weak self] data, response, error in // weak self 순환 참조 문제 해결
                    guard let self = self else { return }
                    let successRange = (200..<300)  // 200에서 299까지 값을 갖을 수 있음
                    // data를 받아오고, error가 없을 때 계속 진행
                    guard let data = data, error == nil else { return }
                    let decoder = JSONDecoder() // json 객체에서 Data 유형의 instance로 decoding하는 객체
                    if let response = response as? HTTPURLResponse, successRange.contains(response.statusCode) {// 응답이 성공일 때
                        guard let weatherInformation = try? decoder.decode(WeatherInformation.self, from: data) else { return } // data를 WeatherInformation형태로 decoding
                        DispatchQueue.main.async { // main thread에서 동작
                            self.makeAlarmResultUI(weatherInformation: weatherInformation)
                            self.saveFashionAllInfo(alarmResultUI: self.alarmResultUI!)
                            self.configureView()
                        }
                    }
                    else {
                        guard let errorMesaage = try? decoder.decode(ErrorMessage.self, from: data) else { return } // 에러 메세지
                        DispatchQueue.main.async { // main thread에서 동작
                            self.showAlert(message: errorMesaage.message)
                        }
                    }
                }.resume()
        } catch {
            print(error)
        }
    }
    
    func makeAlarmResultUI(weatherInformation: WeatherInformation){
        let recommend = self.recommendClothes( degree: (weatherInformation.temp.minTemp - 273.15 + weatherInformation.temp.maxTemp - 273.15)/2 )
        let weatherInfo = weatherInformation.weather.first
        self.alarmResultUI = AlarmResultUI(weather: weatherInfo!.description, maxTmp: weatherInformation.temp.maxTemp - 273.15, minTmp: weatherInformation.temp.minTemp - 273.15, recommend: recommend)
    }
    
    func configureView() {
        guard let alarmResultUI = self.alarmResultUI else { return }
        weatherStackView.isHidden = false
        
        self.cityNameLabel.text =  self.location!.address
        
        let weather = alarmResultUI.weather
        chooseImgFromWeather(weather: weather)
        if(weather.contains("비") || weather.contains("눈")){
            setupUI()
        }
        else if(self.view.subviews.contains(skView)){
            skView.removeFromSuperview()
        }
        self.weatherDescriptionLabel.text = weather // 현재 날씨 라벨에 정보 표시
        self.minTempLabel.text = "최저: \(Int(alarmResultUI.minTmp))℃" // 최저온도 섭씨온도 변환 후 라벨에 표시
        self.maxTempLabel.text = "최고: \(Int(alarmResultUI.maxTmp))℃" // 최고온도 섭씨온도 변환 후 라벨에 표시
        self.recommendClothesLabel.text = alarmResultUI.recommend
    }
    
    func showAlert(message: String) { // 에러시 alert 하는 함수
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func recommendClothes(degree: Double) -> String { // return을 enum 처리 -> enum 공부하기
        // 범위는 enum처리 아님
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
        if( self.view.subviews.contains(skView) ){ return }
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
    
    private func chooseImgFromWeather(weather: String){ // 중복처리 -> for 문으로 배열에 맑음, 구름, 비, 눈 넣고
        
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

