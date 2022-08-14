//
//  AlarmListViewController.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/13.
//

import UIKit

class AlarmListViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    private var AlarmList = [Alarm]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.collectionViewLayout = UICollectionViewLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
    }

}

extension AlarmListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlarmCell", for: indexPath) as? AlarmCell else { return UICollectionViewCell() }
        return cell
    }
}

extension AlarmListViewController: UICollectionViewDelegateFlowLayout {
}

extension AlarmListViewController: UICollectionViewDelegate {
}
