//
//  ViewController.swift
//  FAMCalendarView
//
//  Created by Kazuya Ueoka on 2016/03/26.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    let numberOfRows :CGFloat = 4.0
    let cellIdentifier :String = "cellIdentifier"
    var fetchResult :PHFetchResult?
    
    lazy var layout :UICollectionViewFlowLayout = {
        let result :UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        result.itemSize = self.itemSize()
        result.minimumLineSpacing = 1.0
        result.minimumInteritemSpacing = 1.0
        return result
    }()
    
    lazy var collectionView :UICollectionView = {
        let result :UICollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: self.layout)
        result.registerClass(FAMAlbumViewCell.self, forCellWithReuseIdentifier: self.cellIdentifier)
        result.delegate = self
        result.dataSource = self
        result.backgroundColor = UIColor.whiteColor()
        return result
    }()
    
    lazy var searchButton :UIBarButtonItem = {
        return UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Search, target: self, action: #selector(ViewController.onSearchButtonDidTapped(_:)))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.rightBarButtonItems = [self.searchButton]
        
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.collectionView)
        self.checkPhotoLibraryAuthorization()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.collectionView.frame = self.view.bounds
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func checkPhotoLibraryAuthorization()
    {
        let status :PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .NotDetermined:
            PHPhotoLibrary.requestAuthorization({ (status :PHAuthorizationStatus) in
                if (status == .Authorized)
                {
                    self.loadPhotos()
                }
            })
            break
        case .Authorized:
            self.loadPhotos()
            break
        case .Denied:
            print("\(#function) denied")
            break
        case .Restricted:
            print("\(#function) restricted")
            break
        }
    }
    
    func loadPhotos()
    {
        guard let cameraRollCollection :PHAssetCollection = PHAssetCollection.fetchAssetCollectionsWithType(.SmartAlbum, subtype: .SmartAlbumUserLibrary, options: nil).firstObject as? PHAssetCollection else
        {
            return
        }
        
        self.fetchResult = PHAsset.fetchAssetsInAssetCollection(cameraRollCollection, options: nil)
        if NSThread.isMainThread()
        {
            self.collectionView.reloadData()
        }
        else
        {
            dispatch_async(dispatch_get_main_queue(), {[weak self] in
                if let _weakSelf = self
                {
                    _weakSelf.collectionView.reloadData()
                }
            })
        }
    }
    
    //MARK: events
    
    func onSearchButtonDidTapped(button :UIBarButtonItem)
    {
        let calendarViewController :FAMCalendarViewController = FAMCalendarViewController(withDate: NSDate())
        let navigationController :UINavigationController = UINavigationController(rootViewController: calendarViewController)
        self.presentViewController(navigationController, animated: true, completion: nil)
    }
    
    //MARK: size
    
    func itemSize() -> CGSize
    {
        let width :CGFloat = ((UIScreen.mainScreen().bounds.size.width - (self.numberOfRows - 1.0)) / self.numberOfRows)
        return CGSize(width: width, height: width)
    }
    
    //MARK: UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.fetchResult?.count ?? 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell :FAMAlbumViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(self.cellIdentifier, forIndexPath: indexPath) as! FAMAlbumViewCell
        if let asset :PHAsset = self.fetchResult?.objectAtIndex(indexPath.row) as? PHAsset
        {
            self.collectionViewCell(cell, configureWithAsset: asset)
        }
        
        return cell
    }
    
    //MARK: collectionView cell configure
    func collectionViewCell(configureCell: FAMAlbumViewCell, configureWithAsset asset: PHAsset)
    {
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: self.itemSize(), contentMode: .AspectFill, options: nil, resultHandler: { (image :UIImage?, info :[NSObject : AnyObject]?) in
            configureCell.imageView.image = image
        })
    }
}

