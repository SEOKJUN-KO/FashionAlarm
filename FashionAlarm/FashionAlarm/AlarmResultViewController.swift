//
//  AlarmResultViewController.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/15.
//

import UIKit

class AlarmResultViewController: UIViewController {
    
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var weatherDescriptionLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    @IBOutlet weak var weatherStackView: UIStackView!

    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        getCurrentWeather()
    }
    
    func configureView(weatherInformation: WeatherInformation) {
        self.cityNameLabel.text = weatherInformation.name // 도시 이름 라벨에 표시
        if let weather = weatherInformation.weather.first {
            self.weatherDescriptionLabel.text = weather.description // 현재 날씨 라벨에 정보 표시
        }
        self.tempLabel.text = "\(Int(weatherInformation.temp.temp - 273.15))℃" // 섭씨온도 변환
        self.minTempLabel.text = "최저: \(Int(weatherInformation.temp.minTemp - 273.15))℃" // 최저온도 섭씨온도 변환 후 라벨에 표시
        self.maxTempLabel.text = "최고: \(Int(weatherInformation.temp.maxTemp - 273.15))℃" // 최고온도 섭씨온도 변환 후 라벨에 표시
    }
    
    func showAlert(message: String) { // 에러시 alert 하는 함수
        let alert = UIAlertController(title: "에러", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 날씨 정보 받아오는 함수
    func getCurrentWeather() {
        
        guard let url = URL(string: "https://api.openweathermap.org/data/2.5/weather?lat=37.566627714098&lon=126.85062957695&appid=ff922c126429116c4fc0db7be1ee99af&lang=kr") else { return }
        
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
}

extension AlarmResultViewController {
    private func recommendClothes(degree: Double) -> String {
        if( degree >= 28 ){ return "민소매, 반팔, 반바지, 짧은 치마, 린넨 옷"
        } else if( degree >= 23 ) { return "반팔, 얇은 셔츠, 반바지, 면바지"
        } else if( degree >= 20) { return "블라우스, 긴팔 티, 면바지, 슬랙스"
        } else if( degree >= 17) { return "얇은 가디건, 니트, 맨투맨, 후드, 긴 바지"
        } else if( degree >= 12) { return "자켓, 가디건, 청자켓, 니트, 스타킹, 기모바지"
        } else if( degree >= 9) { return "트렌치 코트, 야상, 점퍼, 스타킹, 기모바지"
        } else if ( degree >= 5) { return "울 코트, 히트택, 가죽 옷, 기모"
        } else { return "패딩, 두꺼운 코트, 누빔 옷, 기모, 목도리" }
    }
}

