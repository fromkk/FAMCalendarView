//
//  FAMCalendarViewController.swift
//  FAMCalendarView
//
//  Created by Kazuya Ueoka on 2016/03/26.
//  Copyright © 2016年 fromKK. All rights reserved.
//

import UIKit

//MARK: NSDate extention

public protocol FAMCalendarViewDataSource
{
    func imageForCalendarView(calendarView :FAMCalendarView, atDate date :NSDate) -> UIImage
}

//MARK: FAMCalendarHeaderView

public class FAMCalendarHeaderView :UICollectionReusableView
{
    public static let headerIdentifier :String = "headerIdentifier"
    lazy var yearLabel :UILabel = {
        let result :UILabel = UILabel()
        result.textAlignment = NSTextAlignment.Center
        result.font = UIFont(name: "Avenir-Medium", size: 12.0)
        result.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        result.numberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.ByWordWrapping
        return result
    }()
    lazy var monthLabel :UILabel = {
        let result :UILabel = UILabel()
        result.textAlignment = NSTextAlignment.Center
        result.font = UIFont(name: "Avenir-Medium", size: 40.0)
        result.textColor = UIColor(red: 0.25, green: 0.25, blue: 0.25, alpha: 1.0)
        result.numberOfLines = 1
        result.lineBreakMode = NSLineBreakMode.ByWordWrapping
        return result
    }()
    lazy var backButton :UIButton = {
        let button :UIButton = UIButton(type: .Custom)
        button.setTitle("<", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        return button
    }()
    lazy var forwardButton :UIButton = {
        let button :UIButton = UIButton(type: .Custom)
        button.setTitle(">", forState: .Normal)
        button.setTitleColor(UIColor.blueColor(), forState: .Normal)
        return button
    }()
    var didSet :Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self._commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._commonInit()
    }
    
    private func _commonInit()
    {
        if didSet
        {
            return
        }
        
        didSet = true
        self.addSubview(self.yearLabel)
        self.addSubview(self.monthLabel)
        self.addSubview(self.backButton)
        self.addSubview(self.forwardButton)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        let horizontalMargin :CGFloat = 16.0
        let verticalMergin :CGFloat = 4.0
        let yearSize :CGSize = self.yearLabel.sizeThatFits(CGSize(width: (self.frame.size.width - horizontalMargin) / 2.0, height: 20.0))
        let monthSize :CGSize = self.monthLabel.sizeThatFits(CGSize(width: (self.frame.size.width - horizontalMargin) / 2.0, height: 40.0))
        let totalHeight :CGFloat = yearSize.height + verticalMergin + monthSize.height
        self.yearLabel.frame = CGRect(x: horizontalMargin, y: (self.frame.size.height - totalHeight) / 2.0, width: self.frame.size.width - horizontalMargin * 2.0, height: yearSize.height)
        self.monthLabel.frame = CGRect(x: horizontalMargin, y: self.yearLabel.frame.maxY + verticalMergin, width: self.frame.size.width - horizontalMargin * 2.0, height: monthSize.height)
        
        self.backButton.frame = CGRect(x: horizontalMargin, y: (self.frame.size.height - 20.0) / 2.0, width: 20.0, height: 20.0)
        self.forwardButton.frame = CGRect(x: self.frame.size.width - horizontalMargin - 20.0, y: (self.frame.size.height - 20.0) / 2.0, width: 20.0, height: 20.0)
    }
}

//MARK: FAMCalendarViewCell

public class FAMCalendarViewCell :UICollectionViewCell
{
    static let cellIdentifier :String = "calendarViewCellIdentifier"
    lazy var dateLabel :UILabel = {
        let result :UILabel = UILabel()
        result.textAlignment = .Center
        result.backgroundColor = UIColor.clearColor()
        return result
    }()
    lazy var imageView :UIImageView = {
        let result :UIImageView = UIImageView()
        result.contentMode = .ScaleAspectFill
        result.clipsToBounds = true
        result.backgroundColor = UIColor.clearColor()
        return result
    }()
    var active :Bool = false {
        didSet
        {
            if active
            {
                self.dateLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.03)
            } else
            {
                self.dateLabel.textColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
                self.backgroundColor = UIColor(white: 0.0, alpha: 0.08)
            }
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self._commonInit()
    }
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self._commonInit()
    }
    private var didSet :Bool = false
    private func _commonInit()
    {
        if didSet
        {
            return
        }
        
        didSet = true
        self.contentView.addSubview(self.imageView)
        self.contentView.addSubview(self.dateLabel)
        self.layer.cornerRadius = 6.0
        self.layer.masksToBounds = true
    }
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.bounds
        self.dateLabel.frame = self.bounds
    }
}

public class FAMCalendarViewLayout :UICollectionViewFlowLayout
{
    private var margin :CGFloat = 2.0
    public static let numberOfWeekDays :CGFloat = 7.0
    lazy private var calendarItemSize :CGSize = {
        let size :CGFloat = ((UIScreen.mainScreen().bounds.size.width - numberOfWeekDays) / numberOfWeekDays)
        return CGSize(width: size - self.margin, height:size - self.margin)
    }()
    
    override init() {
        super.init()
        
        self.itemSize = self.calendarItemSize
        self.minimumLineSpacing = self.margin
        self.minimumInteritemSpacing = self.margin
        self.sectionInset = UIEdgeInsets(top: self.margin, left: 0.0, bottom: 0.0, right: 0.0)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public class FAMCalendarView :UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    private var didSet :Bool = false
    public var numberOfWeeks :Int = 0
    public var numberOfDays :Int = 0
    
    public var year :Int = 0
    public var month :Int = 0
    public var date :NSDate? {
        didSet
        {
            guard let currentDate = date else
            {
                return
            }
            
            let calendar :NSCalendar = NSCalendar.currentCalendar()
            calendar.locale = NSLocale.systemLocale()
            calendar.timeZone = NSTimeZone.systemTimeZone()
            let comp1 :NSDateComponents = calendar.components([.Year, .Month, .Day], fromDate: currentDate)
            comp1.month += 1
            comp1.day = 0
            
            guard let _date = calendar.dateFromComponents(comp1) else
            {
                return
            }
            let comp2 :NSDateComponents = calendar.components([.Day, .WeekOfMonth, .Year, .Month], fromDate: _date)
            self.numberOfWeeks = comp2.weekOfMonth
            self.numberOfDays = comp2.day
            self.year = comp2.year
            self.month = comp2.month
        }
    }
    public var calendarDataSource :FAMCalendarViewDataSource?
    
    public var back :(() -> Void)?
    public var forward :(() -> Void)?
    
    lazy var calendarHeaderView :FAMCalendarHeaderView = {
        let result :FAMCalendarHeaderView = FAMCalendarHeaderView()
        
        return result
    }()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self._commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self._commonInit()
    }
    
    private func _commonInit()
    {
        if didSet
        {
            return
        }
        
        didSet = true
        self.backgroundColor = UIColor.whiteColor()
        self.delegate = self
        self.dataSource = self
        self.registerClass(FAMCalendarViewCell.self, forCellWithReuseIdentifier: FAMCalendarViewCell.cellIdentifier)
        self.registerClass(FAMCalendarHeaderView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: FAMCalendarHeaderView.headerIdentifier)
    }
    
    //MARK: UICollectionViewDataSource
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.numberOfWeeks
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int(FAMCalendarViewLayout.numberOfWeekDays)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell :FAMCalendarViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(FAMCalendarViewCell.cellIdentifier, forIndexPath: indexPath) as! FAMCalendarViewCell
        if let currentDate = self.date?.dateFromIndexPath(indexPath)
        {
            cell.dateLabel.text = "\(currentDate.day())"
            cell.imageView.image = self.calendarDataSource?.imageForCalendarView(self, atDate: currentDate)
            cell.active = currentDate.isEqual(toYear: self.year, month: self.month)
            
        }
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view :FAMCalendarHeaderView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: FAMCalendarHeaderView.headerIdentifier, forIndexPath: indexPath) as! FAMCalendarHeaderView
        view.yearLabel.text = "\(self.year)"
        view.monthLabel.text = "\(self.month)"
        view.backButton.addTarget(self, action: #selector(FAMCalendarView.onBackButtonDidTapped(_:)), forControlEvents: .TouchUpInside)
        view.forwardButton.addTarget(self, action: #selector(FAMCalendarView.onForwardButtonDidTapped(_:)), forControlEvents: .TouchUpInside)
        return view
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        if 0 == section
        {
            return CGSize(width: self.frame.size.width, height: 120.0)
        } else
        {
            return CGSize.zero
        }
    }
    
    //MARK: events
    func onBackButtonDidTapped(button :UIButton)
    {
        self.back?()
    }
    
    func onForwardButtonDidTapped(button :UIButton)
    {
        self.forward?()
    }
}

public class FAMCalendarViewController :UIViewController
{
    public var date :NSDate
    
    lazy private var closeButton :UIBarButtonItem = {
        let result :UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Stop, target: self, action: #selector(FAMCalendarViewController.onCloseButtonDidTapped(_:)))
        return result
    }()
    
    private var currentCalendarView :FAMCalendarView?
    private var lastPoint :CGPoint?
    
    lazy private var leftSwipeGesture :UISwipeGestureRecognizer = {
        let result :UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FAMCalendarViewController.onSwipeGestureDidReceived(_:)))
        result.direction = .Left
        return result
    }()
    lazy private var rightSwipeGesture :UISwipeGestureRecognizer = {
        let result :UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(FAMCalendarViewController.onSwipeGestureDidReceived(_:)))
        result.direction = .Right
        return result
    }()
    lazy private var _contentInset :UIEdgeInsets = {
        return UIEdgeInsets(top: UIApplication.sharedApplication().statusBarFrame.height + (self.navigationController?.navigationBar.frame.height ?? 0.0), left: 0.0, bottom: 0.0, right: 0.0)
    }()
    
    init(withDate date :NSDate)
    {
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: life cycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.leftBarButtonItems = [self.closeButton]
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.currentCalendarView = self.calendarView(withDate: self.date)
        self.view.backgroundColor = UIColor.whiteColor()
        self.view.addSubview(self.currentCalendarView!)
        self.view.addGestureRecognizer(self.leftSwipeGesture)
        self.view.addGestureRecognizer(self.rightSwipeGesture)
    }
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.currentCalendarView?.frame = self.view.bounds
    }
    
    //MARK: events
    public func onCloseButtonDidTapped(button :UIBarButtonItem)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    public func onSwipeGestureDidReceived(gesture :UISwipeGestureRecognizer)
    {
        if gesture.state != .Ended
        {
            return
        }
        
        if gesture.direction == .Left
        {
            self.forward(true)
        } else if gesture.direction == .Right
        {
            self.back(true)
        }
    }
    
    public func back(animated :Bool)
    {
        let calendarView :FAMCalendarView = self.calendarView(withDate: NSDate.date(fromYear: self.currentCalendarView!.year, month: self.currentCalendarView!.month - 1, day: 1))
        self.view.addSubview(calendarView)
        if animated
        {
            calendarView.frame = self.view.bounds
            calendarView.frame.origin.x = -calendarView.frame.size.width
            UIView.animateWithDuration(0.33, animations: {
                var moveFrame :CGRect = self.view.frame
                moveFrame.origin.x = moveFrame.size.width
                self.view.frame = moveFrame
            }, completion: { (finished :Bool) in
                self.view.frame.origin.x = 0.0
                self.currentCalendarView?.removeFromSuperview()
                self.currentCalendarView = calendarView
                self.currentCalendarView?.frame = self.view.bounds
            })
        } else
        {
            self.currentCalendarView?.removeFromSuperview()
            self.currentCalendarView = calendarView
        }
    }
    
    public func forward(animated :Bool)
    {
        let calendarView :FAMCalendarView = self.calendarView(withDate: NSDate.date(fromYear: self.currentCalendarView!.year, month: self.currentCalendarView!.month + 1, day: 1))
        self.view.addSubview(calendarView)
        if animated
        {
            calendarView.frame = self.view.bounds
            calendarView.frame.origin.x = calendarView.frame.size.width
            UIView.animateWithDuration(0.33, animations: {
                var moveFrame :CGRect = self.view.frame
                moveFrame.origin.x = -moveFrame.size.width
                self.view.frame = moveFrame
            }, completion: { (finished :Bool) in
                self.view.frame.origin.x = 0.0
                self.currentCalendarView?.removeFromSuperview()
                self.currentCalendarView = calendarView
                self.currentCalendarView?.frame = self.view.bounds
            })
        } else
        {
            self.currentCalendarView?.removeFromSuperview()
            self.currentCalendarView = calendarView
        }
    }
    
    //MARK: elements
    func calendarView(withDate date :NSDate) -> FAMCalendarView
    {
        let result :FAMCalendarView = FAMCalendarView(frame: self.view.bounds, collectionViewLayout: FAMCalendarViewLayout())
        result.date = date
        result.contentInset = self._contentInset
        result.back = {
            self.back(true)
        }
        result.forward = {
            self.forward(true)
        }
        return result
    }
}