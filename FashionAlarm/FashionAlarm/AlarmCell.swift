//
//  AlarmCell.swift
//  FashionAlarm
//
//  Created by 고석준 on 2022/08/14.
//

import UIKit

class AlarmCell: UICollectionViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 3.0
        contentView.layer.borderWidth = 1.0
        contentView.layer.borderColor = UIColor.black.cgColor
    }

}
