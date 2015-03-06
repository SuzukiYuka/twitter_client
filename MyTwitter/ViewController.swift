//
//  ViewController.swift
//  MyTwitter
//
//  Created by nagata on 9/14/14.
//  Copyright (c) 2014 Suzuki Yuka. All rights reserved.
//

import UIKit
import Accounts
import Social

class ViewController: UIViewController , UITableViewDelegate ,UITableViewDataSource{
    
    
    var array:NSArray? = NSArray()
    @IBOutlet var timelineTableView:UITableView? = UITableView()
    
    
    
    /* tweet */
    @IBAction func tweet(sender:AnyObject){
        var tweetPostVC:SLComposeViewController? = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
        self.presentViewController(tweetPostVC!, animated: true, completion: nil)
    }
    
    @IBAction func reload(sender:AnyObject){
        getTimeline()
    }
    
    /* timeline 取得 */
    func getTimeline(){
        
        var account:ACAccountStore? = ACAccountStore()
        var accountType:ACAccountType? = ACAccountType()
        accountType! = account!.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        let handler: ACAccountStoreRequestAccessCompletionHandler =
        {
            granted, error in
            if(!granted) {
                println("アクセス拒否")
            } else {
                println("アクセス許可")
                var accounts:NSArray? = NSArray()
                accounts! = account!.accountsWithAccountType(accountType)
                if accounts!.count > 0 {
                    //アカウントが複数ある場合１つ選ぶ
                    var twitterAccount:ACAccount = accounts!.lastObject as ACAccount
                    var reqestAPI:NSURL = NSURL(string:"https://api.twitter.com/1.1/statuses/home_timeline.json")!
                    
                    var params:NSMutableDictionary? = NSMutableDictionary()
                    params!.setObject("100", forKey: "count")
                    params!.setObject("1", forKey: "include_entities")
                    
                    var posts:SLRequest? = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: SLRequestMethod.GET, URL: reqestAPI, parameters: params)
                    
                    posts!.account = twitterAccount
                    
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                    
                    var pHandler:SLRequestHandler? = {
                        (response,urlResponse,error) in
                        var err: NSError?
                        if let jsonArray = NSJSONSerialization.JSONObjectWithData(response, options: NSJSONReadingOptions.MutableLeaves, error: &err) as? NSArray {
                            self.array = jsonArray
                            
                            if self.array!.count != 0 {
                                dispatch_async(dispatch_get_main_queue(), {self.timelineTableView!.reloadData()})
                            }
                            
                        
                            
                        } else {
                            println(err!.localizedDescription)
                            
                        }
                    }
                    posts!.performRequestWithHandler(pHandler)
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                }else{
                    println(error.localizedDescription)
                }
            }
        }
        account!.requestAccessToAccountsWithType(accountType, options: nil, completion: handler)
        
    }
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        getTimeline()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return array!.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        var tweetTextView:UITextView = cell.viewWithTag(3) as UITextView
        var userLabel:UILabel = cell.viewWithTag(1) as UILabel
        var userIDLabel:UILabel = cell.viewWithTag(2) as UILabel
        var userImgView:UIImageView = cell.viewWithTag(4) as UIImageView
        
        var tweet:NSDictionary = array![indexPath.row] as NSDictionary
        var userInfo:NSDictionary = tweet["user"]! as NSDictionary
        
        println(tweet)
        
        tweetTextView.text = tweet["text"] as NSString
        userLabel.text = userInfo["name"] as NSString
        var userID = userInfo["screen_name"] as NSString
        userIDLabel.text = "@\(userID)"
        var userImgPath:NSString = userInfo["profile_image_url"] as NSString
        var userImgUrl:NSURL = NSURL(string: userImgPath)!
        var userImgPathData:NSData = NSData(contentsOfURL: userImgUrl)!
        userImgView.image = UIImage(data: userImgPathData)
        
        return cell
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

