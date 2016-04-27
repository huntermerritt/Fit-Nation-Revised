//
//  PEClassViewController.swift
//  PE Fitbit Build
//
//  Created by hmerritt and adrewno1 on 4/8/16.
//  Copyright © 2016 shedtechsolutions. All rights reserved.
// revised
// new comment

import UIKit
import OAuthSwift

class PEClassViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var defaults = NSUserDefaults.standardUserDefaults()
    var classes: [String] = []
    var friendClasses: [String] = []
    var sendingClassName = ""
    var oauthswift : OAuth2Swift! = nil
    var parameters: [String: AnyObject]!
    var headers : [String: String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if defaults.arrayForKey("classes") != nil
        {
            classes = defaults.arrayForKey("classes") as! [String]
        }
        if defaults.arrayForKey("friendClasses") != nil
        {
            friendClasses = defaults.arrayForKey("friendClasses") as! [String]
        }
        
        self.title = "Groups"
        
        tableView.rowHeight = 100
        
        tableView.layer.cornerRadius = 25
        tableView.clipsToBounds = true
    }
    
    
    @IBAction func newClass(sender: AnyObject)
    {
        let alert = UIAlertController(title: "New Sub Group", message: "What do you want to name your new Sub Group?", preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textfield) in
            textfield.placeholder = "Group Name"
            
            
        }
        
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: { (action) in
            
            if alert.textFields![0].text != ""
            {
                self.classes.append(alert.textFields![0].text!)
                
                alert.dismissViewControllerAnimated(true, completion: nil)
                self.defaults.setObject(self.classes, forKey: "classes")
                self.tableView.reloadData()
            }
            
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: { (action) in
            
            alert.dismissViewControllerAnimated(true, completion: nil)
            
            self.tableView.reloadData()
        }))
        
        
        
        presentViewController(alert, animated: true, completion: nil)
        
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return classes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        
        cell.layer.cornerRadius = 25
        cell.clipsToBounds = true
        
        cell.textLabel?.text = classes[indexPath.row]
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        sendingClassName = classes[indexPath.row]
        
        performSegueWithIdentifier("specific", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "specific"
        {
            
            let next = segue.destinationViewController as! specificClassViewController
            
            next.className = sendingClassName
            next.parameters = self.parameters
            next.oauthswift = self.oauthswift
            next.headers = self.headers
            
            
        }
        
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var temp: [UITableViewRowAction] = []
        
        var remove = UITableViewRowAction(style: .Default, title: "Remove Group") { (action, path) in
            
            tableView.beginUpdates()
            
            var titleText = tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text
            
            var loc = self.classes.indexOf((titleText)!)
            
            if loc != nil
            {
                self.classes.removeAtIndex(loc!)
            }
            
            self.defaults.setObject(self.classes, forKey: "classes")
            
            var friendsLoc = self.friendClasses.indexOf(titleText!)
            
            while friendsLoc != nil
            {
                self.friendClasses.removeAtIndex(friendsLoc!)
                self.friendClasses.insert(" ", atIndex: friendsLoc!)
                friendsLoc = self.friendClasses.indexOf(titleText!)
            }
            
            self.defaults.setObject(self.friendClasses, forKey: "friendClasses")
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Bottom)
            
            tableView.endUpdates()
            tableView.reloadData()
            
        }
     
        remove.backgroundColor = UIColor.redColor()
        
        
        temp.append(remove)
        
        
        return temp
        
    }
    
    
    
    
}
