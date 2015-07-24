//
//  ViewController.swift
//  dribbleRefresh
//
//  Created by Robin Malhotra on 22/07/15.
//  Copyright © 2015 Robin Malhotra. All rights reserved.
//

//credits for rocket svg:Rocket by Steve Morris from the Noun Project

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    let tableView=UITableView()
    let refreshControlHeight = 200
    let refreshControl=UIControl()
    let dataArray=1...20
    let rocketView=UIImageView(image: UIImage(named: "rocket"))
    var isRefreshing = false
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func setupViews()
    {
        tableView.frame=CGRectMake(0, 0, view.frame.width, view.frame.height)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)
        tableView.delegate=self
        tableView.dataSource=self
        refreshControl.frame = CGRectMake(CGFloat(0.0), CGFloat(-refreshControlHeight), view.frame.width, CGFloat(refreshControlHeight))
        rocketView.frame=refreshControl.frame
        rocketView.contentMode=UIViewContentMode.ScaleAspectFit
        tableView.addSubview(refreshControl)
        tableView.addSubview(rocketView)
        refreshControl.addTarget(self, action: Selector("sendDataRequest"), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.addTarget(self, action: Selector("startAnimation"), forControlEvents: UIControlEvents.ValueChanged)
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func sendDataRequest()
    {
        print("dataRequest")
    }
    
    func startAnimation()
    {
        let delayInSeconds = 3.0;
        let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayInSeconds * Double(NSEC_PER_SEC)));
        dispatch_after(popTime, dispatch_get_main_queue()) { () -> Void in
            // When done requesting/reloading/processing invoke endRefreshing, to close the control
            self.rocketView.layer.removeAnimationForKey("shakeIt")
            let animation=CABasicAnimation(keyPath: "position.y")
            animation.fromValue = self.rocketView.layer.position.y
            animation.toValue = -1000
            animation.duration = 1.0
            self.rocketView.layer.addAnimation(animation, forKey: "GoingUp")
            self.rocketView.layer.position.y = -100
            
            var loadingInset = self.tableView.contentInset
            loadingInset.top -= CGFloat(self.refreshControlHeight)
            var contentOffset=self.tableView.contentOffset
            contentOffset.y += CGFloat(self.refreshControlHeight)
            
            UIView.animateWithDuration(1.0, animations: { () -> Void in
                self.tableView.contentInset = loadingInset;
                self.tableView.contentOffset = contentOffset;
                print(contentOffset)
                print(loadingInset)
                self.rocketView.frame=self.refreshControl.frame
                })
            self.isRefreshing=false
            
        }
        print("animation")
        let animation = CAKeyframeAnimation(keyPath: "position.x")
        animation.values=[0,1,-1,0]
        animation.keyTimes=[0,0.33,0.66,1]
        animation.duration=0.1
        animation.additive=true
        animation.repeatCount = HUGE
        rocketView.layer.addAnimation(animation, forKey: "shakeIt")
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < -100
        {
            let context = UIGraphicsGetCurrentContext();
            let path=UIBezierPath()
            path.moveToPoint(CGPointZero)
            path.addQuadCurveToPoint(CGPointMake(view.frame.width, 0), controlPoint:CGPointMake(0, -scrollView.contentOffset.y))
            path.fill()
            path.stroke()
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    {
        let minOffsetToTriggerRefresh=refreshControlHeight
        if scrollView.contentOffset.y < -CGFloat(minOffsetToTriggerRefresh) && !isRefreshing
        {
            isRefreshing = true

            var loadingInset = scrollView.contentInset
            loadingInset.top += CGFloat(refreshControlHeight)
            let contentOffset=scrollView.contentOffset
            
            UIView.animateWithDuration(0.1, animations: { () -> Void in
                scrollView.contentInset = loadingInset;
                scrollView.contentOffset = contentOffset;
                }, completion: { (completion) -> Void in
            self.refreshControl.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            })
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell=tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!
        
        if(cell != nil)
        {
            cell=UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "cell")
        }
        cell.textLabel?.text = String(indexPath.row)
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

