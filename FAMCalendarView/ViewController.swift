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

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, FAMCalendarViewDataSource, FAMCalendarViewDelegate {

    let numberOfRows :CGFloat = 4.0
    let cellIdentifier :String = "cellIdentifier"
    var fetchResult :PHFetchResult?
    var dateAssets :Dictionary<String, UIImage> = [:]
    var dateIndexes :Dictionary<String, Int> = [:]
    let dateFormat :String = "yyyyMMdd"
    var minDate :NSDate?
    var maxDate :NSDate?
    
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
        self.fetchResult?.enumerateObjectsUsingBlock { object, index, stop in
            let asset :PHAsset? = object as? PHAsset
            guard let creationDate :NSDate = asset?.creationDate else
            {
                return
            }
            if nil == self.minDate || self.minDate?.compare(creationDate) == .OrderedDescending
            {
                self.minDate = creationDate
            }
            if nil == self.maxDate || self.maxDate?.compare(creationDate) == .OrderedAscending
            {
                self.maxDate = creationDate
            }

            let dateString :String = creationDate.formatedString(self.dateFormat)
            
            if nil != asset
            {
                self.loadImage(dateString, asset: asset!)
                self.dateIndexes[dateString] = index
            }
        }
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
    
    func loadImage(dateString :String, asset :PHAsset)
    {
        let size :CGSize = CGSize(width: self.view.frame.width / 7.0, height: self.view.frame.width / 7.0)
        PHImageManager.defaultManager().requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) in
            self.dateAssets[dateString] = image
        }
    }
    
    //MARK: events
    
    func onSearchButtonDidTapped(button :UIBarButtonItem)
    {
        guard let collectionViewLayout :UICollectionViewFlowLayout = self.collectionView.collectionViewLayout as? UICollectionViewFlowLayout else
        {
            return
        }

        let contentOffset :CGPoint = CGPoint(x: self.collectionView.contentOffset.x + (collectionViewLayout.itemSize.width / 2.0), y: self.collectionView.contentOffset.y + self.collectionView.contentInset.top + (self.navigationController?.navigationBar.frame.size.height ?? 0.0) + (UIApplication.sharedApplication().statusBarFrame.size.height ?? 0.0) + (collectionViewLayout.itemSize.height / 2.0))
        print(contentOffset)
        guard let indexPath :NSIndexPath = self.collectionView.indexPathForItemAtPoint(contentOffset) else
        {
            return
        }

        guard let date :NSDate = self.fetchResult?.objectAtIndex(indexPath.row).creationDate else
        {
            return
        }

        let calendarViewController :FAMCalendarViewController = FAMCalendarViewController(withDate: date, dataSource: self, delegate: self)
        let navigationController :FAMCalendarNavigationController = FAMCalendarNavigationController(rootViewController: calendarViewController)
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
    
    //MARK: FAMCalendarViewDataSource
    func imageForCalendarView(calendarView: FAMCalendarView, atDate date: NSDate) -> UIImage? {
        let dateString :String = date.formatedString(self.dateFormat)
        guard let image :UIImage = self.dateAssets[dateString] else
        {
            return nil
        }
        
        return image
    }

    func calendarViewMinDate() -> NSDate? {
        return self.minDate
    }

    func calendarViewMaxDate() -> NSDate? {
        return self.maxDate
    }
    
    //MARK: FAMCalendarViewDelegate
    func calendarView(calendarView: FAMCalendarView, didSelectedDate date: NSDate) {
        let dateString :String = date.formatedString(self.dateFormat)
        if let index :Int = self.dateIndexes[dateString]
        {
            let indexPath :NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
            self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
        }
    }
}

