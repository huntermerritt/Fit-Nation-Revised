//
//  ViewController.swift
//  PE Fitbit Build
//
//  Created by hmerritt on 4/7/16.
//  Copyright © 2016 shedtechsolutions. All rights reserved.
// github test

import UIKit
import OAuthSwift
import Charts

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate
{
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var friends: [String] = []
    var stepsArray: [Int] = []
    var defaults = NSUserDefaults.standardUserDefaults()
    var classes: [String] = []
    var savedFriends: [String] = []
    var friendClasses: [String] = []
    var gradeNum = 0.0
    var oauthswift : OAuth2Swift! = nil
    var parameters: [String: AnyObject]!
    var headers : [String: String]!
    
    let step = [3523.0]
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.rowHeight = 80
        tableView.clipsToBounds = true
    }

    
    
    
    override func viewDidAppear(animated: Bool) {
        loading()
        
        oauthswift.accessTokenBasicAuthentification = true
        oauthswift.client.get("https://api.fitbit.com/1/user/-/friends/leaderboard.json", parameters: parameters, headers: headers, success: { (data, response) -> Void in
            
            
            let dataString = NSString(data: data, encoding: NSUTF8StringEncoding)
            print(dataString)
            
            let jsonDict : NSDictionary!
            do
            {
                jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
                
                let friendsDict = jsonDict["friends"] as! NSArray
                
                self.friends = []
                self.stepsArray = []
                
                for num in 0 ..< friendsDict.count
                {
                    let alex = friendsDict[num]
                    let average = alex["average"] as! NSDictionary
                    let steps = average["steps"] as! Int
                    let info = alex["user"] as! NSDictionary
                    let name = info["displayName"] as! String
                    let info2 = info["encodedId"] as! String
                    
                    
                    
                    self.friends.append(name)
                    self.stepsArray.append(steps)
                    
                }
                
                
                for temp in 0 ..< self.friends.count
                {
                    if self.savedFriends.indexOf(self.friends[temp]) == nil
                    {
                        self.savedFriends.append(self.friends[temp])
                        self.friendClasses.append("  ")
                        
                        
                        
                    }
                }
                
                self.tableView.reloadData()
                
                self.defaults.setObject(self.savedFriends, forKey: "friends")
                self.defaults.setObject(self.friendClasses, forKey: "friendClasses")
                
                
            }catch{
                print(error)
            }
            
            
        }) { (error) -> Void in
            
            print("Error: " + error.localizedDescription)
        }
        
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return friends.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
    
   
        
        let studentClass = savedFriends.indexOf(friends[indexPath.row])
        
        if studentClass != nil
        {
            let classIdentifier = friendClasses[studentClass!]
            
            cell.textLabel?.text = friends[indexPath.row] + " : " + classIdentifier
            cell.detailTextLabel?.text = "Daily Step Average: " + "\(stepsArray[indexPath.row])"
        }
        else
        {
            cell.textLabel?.text = friends[indexPath.row]
            cell.detailTextLabel?.text = "Daily Step Average: " + "\(stepsArray[indexPath.row])"
        }

        cell.layer.borderColor = UIColor.whiteColor().CGColor
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
    
    func loadData()
    {
        print("Refreshing")
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool
    {
        return false
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
            
            let alert = UIAlertController()
            
            var actions: [UIAlertAction] = []
            
            print(classes)
            
            for num in 0 ..< classes.count
            {
                
                actions.append(UIAlertAction(title: classes[num], style: .Default, handler: { (action) in
                    
                    
                    print(self.friendClasses.count)
                    
                    self.friendClasses.insert(action.title!, atIndex: indexPath.row)
                    
                    
                    self.friendClasses.removeAtIndex(indexPath.row + 1)
                    self.defaults.setObject(self.friendClasses, forKey: "friendClasses")
                    self.tableView.reloadData()
                    
                    
                }))
                
                
                alert.addAction(actions[num])
            }
            
            alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) in
                
                alert.dismissViewControllerAnimated(true, completion: nil)
            }))
            
            presentViewController(alert, animated: true, completion: nil)
            
        
        
    }
    
    func getGrade(steps: Int)->String
    {
        print(gradeNum)
        
        let newSteps: Double = (Double)(steps)
        
        var grade = newSteps / gradeNum
        print(grade)
        grade = grade * 100
        print(grade)
        grade = grade - (grade % 1)
        
        print(steps)
        print(grade)
        
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
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segue2"
        {
            let vc = segue.destinationViewController as! PEClassViewController
            vc.oauthswift = self.oauthswift
            vc.parameters = self.parameters
            vc.headers = self.headers
        }
        if segue.identifier == "showSettings"
        {
            let popvc = segue.destinationViewController
            popvc.popoverPresentationController?.delegate = self
        }
    }
    
    
    func loading()
    {
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
    }
    
}

