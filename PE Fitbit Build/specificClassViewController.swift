//
//  specificClassViewController.swift
//  PE Fitbit Build
//
//  Created by hmerritt on 4/8/16.
//  Copyright © 2016 shedtechsolutions. All rights reserved.
//

import UIKit
import OAuthSwift

class specificClassViewController: UIViewController, UITableViewDelegate, UITableViewDataSource
{

    
    @IBOutlet weak var tableView: UITableView!
    
    var oauthswift : OAuth2Swift! = nil
    var parameters: [String: AnyObject]!
    var headers : [String: String]!
    var friends: [String] = []
    var stepsArray: [Int] = []
    var defaults = NSUserDefaults.standardUserDefaults()
    var classes: [String] = []
    var savedFriends: [String] = []
    var friendClasses: [String] = []
    var className: String!
    var gradeNum = 0.0
    var date : String = ""
    var stepArray : NSArray!
    var friendsArray: NSArray!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.rowHeight = 80
        
        tableView.clipsToBounds = true
        
        if defaults.arrayForKey("classes") != nil
        {
            classes = defaults.arrayForKey("classes") as! [String]
        }
        if defaults.arrayForKey("friends") != nil
        {
            savedFriends = defaults.arrayForKey("friends") as! [String]
        }
        if defaults.arrayForKey("friendClasses") != nil
        {
            friendClasses = defaults.arrayForKey("friendClasses") as! [String]
        }
        if defaults.objectForKey("grade") != nil
        {
            gradeNum = defaults.objectForKey("grade") as! Double
        }
        if defaults.objectForKey("stepArray") != nil && defaults.objectForKey("friendsArray") != nil
        {
            stepArray = defaults.objectForKey("stepArray") as! NSArray
            friendsArray = defaults.objectForKey("friendsArray") as! NSArray
            reloadTableViewData()
            organize()
        }
        else
        {
            oauthswift.client.get("https://api.fitbit.com/1/user/-/friends/leaderboard.json", parameters: parameters, headers: headers, success: { (data, response) -> Void in
                
                let jsonDict : NSDictionary!
                do
                {
                    jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
                    
                    
                    let friendsDict = jsonDict["friends"] as! NSArray
                    
                    if self.friendsArray == nil || self.friendsArray != friendsDict
                    {
                        self.defaults.setObject(friendsDict, forKey: "friendsArray")
                        self.reloadTableViewData()
                    }
                    
                    for num in 0 ..< friendsDict.count
                    {

                        let alex = friendsDict[num]
                        let average = alex["average"] as! NSDictionary
                        let steps = average["steps"] as! Int
                        let info = alex["user"] as! NSDictionary
                        let name = info["displayName"] as! String
                        let info2 = info["encodedId"] as! String
                        
                        
                        
                        self.oauthswift.client.get("https://api.fitbit.com/1/user/\(info2)/activities/steps/date/today/1m.json", parameters: self.parameters, headers: self.headers, success: { (data, response) -> Void in
                            
                            let jsonDict : NSDictionary!
                            do
                            {
                                jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
                                
                                let infoo = jsonDict["activities-steps"] as! NSArray
                                self.stepArray = infoo
                                self.defaults.setObject(self.stepArray, forKey: "stepArray")
                            }
                            catch
                            {
                                print("error")
                            }
                            
                            }, failure: { (error) -> Void in
                                print(error)
                                
                        })
                        self.friends.append(name)
                        self.stepsArray.append(steps)
                        
                    }
                
                    self.tableView.reloadData()
                }catch{
                    print("Error")
                    print(error)
                }
                
                }) { (error) -> Void in
                    print(error)
            }
        }
        if defaults.objectForKey("friendsArray") != nil
        {
            friendsArray = defaults.objectForKey("friendsArray") as! NSArray
            reloadTableViewData()
            organize()
        }
        
        if gradeNum == 0
        {
            gradeNum = 10000
            
            let alert = UIAlertController(title: "Welcome", message: "Please set a perfect step score this will be the number you believe people should hit in daily steps to get a 100%. You can always change this in the settings.", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler({ (textfield) in
                
                textfield.placeholder = "Ex: 10000"
                textfield.keyboardType = UIKeyboardType.NumberPad
            })
            
            alert.addAction(UIAlertAction(title: "Done", style: .Default, handler: { (action) in
                
                if alert.textFields![0].text != ""
                {
                    
                    self.defaults.setObject((Int)(alert.textFields![0].text!), forKey: "grade")
                    self.gradeNum = (Double)(alert.textFields![0].text!)!
                    
                    alert.dismissViewControllerAnimated(true, completion: nil)
                    self.tableView.reloadData()
                }
                
            }))
            
            presentViewController(alert, animated: true, completion: nil)
        }
        self.title = className
    }
    
    override func viewDidAppear(animated: Bool)
    {
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return friends.count
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("showStudentView", sender: self)
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
        let studentClass = savedFriends.indexOf(friends[indexPath.row])
        
        
        if studentClass != nil
        {
            let classIdentifier = friendClasses[studentClass!]
            
            cell.textLabel?.text = friends[indexPath.row] + " : " + classIdentifier
            cell.detailTextLabel?.text = getGrade(stepsArray[indexPath.row])
            cell.textLabel?.font = UIFont(name: "futura", size: 16)
            cell.detailTextLabel?.font = UIFont(name: "futura", size: 12)
        }
        
        cell.backgroundColor = UIColor.clearColor()
        
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.view.frame.size.width-40, 60))
        
        whiteRoundedView.layer.backgroundColor = UIColor(red: 70, green: 70, blue: 70, alpha: 0.5).CGColor
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 15
        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.layer.cornerRadius = 15
        cell.clipsToBounds = true
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
        
        return cell
    }
    
    
    func getGrade(steps: Int)->String
    {
        print(gradeNum)
        
        let newSteps: Double = (Double)(steps)
        
        var grade = newSteps / gradeNum
        grade = grade * 100
        grade = grade - (grade % 1)
        
        if grade <= 50
        {
            return "F : 50/100"
        }
        else if grade <= 70
        {
            return "D : \(grade)/100"
        }
        else if grade <= 80
        {
            return "C : \(grade)/100"
        }
        else if grade <= 90
        {
            return "B : \(grade)/100"
        }
        else
        {
            return "A : \(grade)/100"
        }
        
        
    }
    
    func reloadTableViewData()
    {
        var newFriends : [String] = []
        var newSteps: [Int] = []
        
        for num in 0 ..< friendsArray.count
        {
            let alex = friendsArray[num]
            let average = alex["average"] as! NSDictionary
            let steps = average["steps"] as! Int
            let info = alex["user"] as! NSDictionary
            let name = info["displayName"] as! String

            newFriends.append(name)
            newSteps.append(steps)
        }
        friends = newFriends
        stepsArray = newSteps
        tableView.reloadData()
    }
    
    func organize()
    {
        var newFriends: [String] = []
        var newSteps: [Int] = []
        for temp in 0 ..< self.friends.count
        {
            let num = self.savedFriends.indexOf(self.friends[temp])
            if num != nil && self.friendClasses[num!] == self.className
            {
                newFriends.append(self.friends[temp])
                newSteps.append(self.stepsArray[temp])
            }
        }
        self.friends = newFriends
        self.stepsArray = newSteps
        self.tableView.reloadData()
    }
    
    @IBAction func showActionSheet(sender: AnyObject) {

        let optionMenu = UIAlertController(title: nil, message: "Choose Grading Period", preferredStyle: .ActionSheet)

        let month = UIAlertAction(title: "1 month (Not including today)", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("1 month")
            
            
        })
        
        let week = UIAlertAction(title: "1 Week (Not including today)", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("1 week")
        })
        
        let five = UIAlertAction(title: "5 Days (Not including today)", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("5 days")
        })
        
        let custom = UIAlertAction(title: "Custom", style: .Default, handler: {
            (alert: UIAlertAction!) -> Void in
            
            let alert = UIAlertController(title: "Custom", message: "Enter start and end date in this format: 'yyyy-MM-dd'", preferredStyle: .Alert)
            alert.addTextFieldWithConfigurationHandler({ (textfield) in
                
                textfield.placeholder = "Ex: 10000"
                textfield.keyboardType = UIKeyboardType.NumberPad
            })
        })

        let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("cancel")
        })

        optionMenu.addAction(month)
        optionMenu.addAction(week)
        optionMenu.addAction(five)
        optionMenu.addAction(custom)
        optionMenu.addAction(cancel)

        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

}
