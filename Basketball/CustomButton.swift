//
//  CustomButton.swift
//  Basketball
//
//  Created by Andriy Trubchanin on 10/17/18.
//  Copyright © 2018 onlinico. All rights reserved.
//

import UIKit

class CustomButton: UIButton
{
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundColor = .lightGray
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.white.cgColor
    }
}
