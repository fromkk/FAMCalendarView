//
//  FAMAlbumViewCell.swift
//  FAMCalendarView
//
//  Created by Kazuya Ueoka on 2016/03/26.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

class FAMAlbumViewCell :UICollectionViewCell
{
    var didSet :Bool = false
    lazy var imageView :UIImageView = {
        let result :UIImageView = UIImageView()
        result.contentMode = .ScaleAspectFill
        result.clipsToBounds = true
        return result
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self._commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }
    
    private func _commonInit()
    {
        if !didSet
        {
            self.contentView.addSubview(self.imageView)
            didSet = true
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.bounds
    }
}
