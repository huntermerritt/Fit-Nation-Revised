import UIKit
import OAuthSwift
import Charts

class homeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPopoverPresentationControllerDelegate
{
    
    
    @IBOutlet weak var overallAvgView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var overallAvgLabel: UILabel!
    @IBOutlet weak var pieChart: PieChartView!

    @IBOutlet weak var settingsButton: UIBarButtonItem!
    var defaults = NSUserDefaults.standardUserDefaults()
    var classes: [String] = []
    var friendClasses: [String] = []
    var sendingClassName = ""
    var oauthswift : OAuth2Swift! = nil
    var parameters: [String: AnyObject]!
    var headers : [String: String]!
    var stepTotal : [Double] = []
    var step = ["Steps", "Steps left"]
    var overallStepAvg: Int = 0
    var savedFriends: [String] = []
    
    var friendsArray: NSArray!
    
    var friendDict: Dictionary<String, NSArray> = [:]
    
    
    var friendsId: [String] = []
    var total = 0.0
    var count = 0.0
    
    override func viewDidLoad()
    {
        
        
        //defaults.setObject(nil, forKey: "classes")
        //defaults.setObject(nil, forKey: "friends")
        //defaults.setObject(nil, forKey: "friendClasses")
        //defaults.setObject(nil, forKey: "grade")
       // defaults.setObject(nil, forKey: "stepArray")
        //defaults.setObject(nil, forKey: "friendsDictionary")
      //  defaults.setObject(nil, forKey: "friendsArray")

        print("viewdidload called")
        pieChart.noDataText = ""
        overallAvgView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        tableView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        pieChart.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        self.settingsButton.title = NSString(string: "\u{2699}\u{0000FE0E}") as String
        if let font = UIFont(name: "Helvetica", size: 18.0)
        {
            self.settingsButton.setTitleTextAttributes([NSFontAttributeName: font], forState: UIControlState.Normal)
        }
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
            stepTotal.append(Double(overallStepAvg))
            stepTotal.append((defaults.objectForKey("grade")) as! Double - Double(overallStepAvg))
        }
        else
        {
            stepTotal.append(Double(overallStepAvg))
            stepTotal.append(10000 - Double(overallStepAvg))
        }
        oauthswift.client.get("https://api.fitbit.com/1/user/-/friends/leaderboard.json", parameters: parameters, headers: headers, success: { (data, response) -> Void in
            
            let jsonDict : NSDictionary!
            do
            {
                jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
                
                
                let friendsDict = jsonDict["friends"] as! NSArray
                
                if self.friendsArray == nil || self.friendsArray != friendsDict
                {
                    self.defaults.setObject(friendsDict, forKey: "friendsArray")
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
                            
                            self.friendDict[name] = infoo
                            self.defaults.setObject(self.friendDict, forKey: "friendsDictionary")
                            
                        }
                        catch
                        {
                            print("error")
                        }
                        
                        self.overallStepAvg = self.getAverageForGroup("all")
                        self.pieChart.animate(xAxisDuration: 2.5, yAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInBounce)
                        self.stepTotal = []
                        if self.defaults.objectForKey("grade") != nil
                        {
                            self.stepTotal.append(Double(self.overallStepAvg))
                            self.stepTotal.append(self.defaults.objectForKey("grade") as! Double - Double(self.overallStepAvg))
                        }
                        else
                        {
                            self.stepTotal.append(Double(self.overallStepAvg))
                            self.stepTotal.append(10000 - Double(self.overallStepAvg))
                        }
                        self.setChart(self.step, values: self.stepTotal)
                        self.overallAvgLabel.text = "\(Int(self.stepTotal[0]))"
                        
                        self.tableView.reloadData()
                        
                        }, failure: { (error) -> Void in
                            print(error)
                            
                    })
                    
                }
                
               
            }catch{
                print("Error")
                print(error)
            }
            
            }) { (error) -> Void in
                print(error)
        }

        
        //overallAvgLabel.text = "\(Int(stepTotal[0]))"
        
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 50, green: 50, blue: 50, alpha: 0.5)
        
        oauthswift.accessTokenBasicAuthentification = true
        
        oauthswift.client.get("https://api.fitbit.com/1/user/-/friends.json", parameters: parameters, headers: headers, success: { (data, response) -> Void in
            
            let jsonDict : NSDictionary!
            do
            {
                jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
                
                let friendsDict = jsonDict["friends"] as! NSArray
                for num in 0 ..< friendsDict.count
                {
                    let alex = friendsDict[num]
                    let info = alex["user"] as! NSDictionary
                    let id = info["encodedId"] as! String
                    self.friendsId.append(id)
                }
//                var newFriends: [String] = []
//                var newSteps: [Int] = []
                
                
//                for numId in 0 ..< self.friendsId.count
//                {
//                self.oauthswift.client.get("https://api.fitbit.com/1/user/\(self.friendsId[numId])/activities/date/2016-04-7.json", parameters: self.parameters, headers: self.headers, success: { (data, response) in
//                    
//                    let jsonDictPersonal : NSDictionary!
//                    
//                    do
//                    {
//                        
//                    jsonDictPersonal = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as? NSDictionary
//                        
//
//                        
//                        var summary : NSDictionary = jsonDictPersonal["summary"] as! NSDictionary
//                        
//                    }
//                    catch
//                    {
//                        
//                    }
//                    
//                    
//                    
//                    }, failure: { (error) in
//                        print(error)
//                })
//                }
                
            }catch{
                print("Error")
                print(error)
            }
            
            self.setChart(self.step, values: self.stepTotal)
            self.tableView.reloadData()
            
        }) { (error) -> Void in
            print(error)
        }
        self.setChart(self.step, values: self.stepTotal)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        overallStepAvg = getAverageForGroup("all")
        pieChart.animate(xAxisDuration: 2.5, yAxisDuration: 2.5, easingOption: ChartEasingOption.EaseInBounce)
        stepTotal = []
        if defaults.objectForKey("grade") != nil
        {
            stepTotal.append(Double(overallStepAvg))
            stepTotal.append(defaults.objectForKey("grade") as! Double - Double(overallStepAvg))
        }
        else
        {
            stepTotal.append(Double(overallStepAvg))
            stepTotal.append(10000 - Double(overallStepAvg))
        }
        setChart(step, values: stepTotal)
        overallAvgLabel.text = "\(Int(stepTotal[0]))"

        tableView.reloadData()
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        
        var dataEntries: [ChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = ChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let pieChartDataSet = PieChartDataSet(yVals: dataEntries, label: "Steps")
        let pieChartData = PieChartData(xVals: dataPoints, dataSet: pieChartDataSet)
        pieChart.data = pieChartData
        pieChart.transparentCircleRadiusPercent = 0.67
        pieChart.userInteractionEnabled = false
        pieChart.drawSliceTextEnabled = false
        pieChart.drawHoleEnabled = true
        pieChart.holeRadiusPercent = 0.65
        pieChart.holeTransparent = true
        pieChart.holeColor = UIColor(red: 50, green: 50, blue: 50, alpha: 0.5)
        pieChart.descriptionText = ""
        pieChart.legend.enabled = false
        
        var colors: [UIColor] = []
        
        for i in 0..<dataPoints.count-1 {
            if i % 2 == 0
            {
                colors.append(UIColor(red: 0.95, green: 0.15, blue: 0.15, alpha: 1))
            }
        }
        colors.append(UIColor(red: 255, green: 20, blue: 20, alpha: 0.2))
        
        pieChartDataSet.colors = colors
    }

    
    @IBAction func addGroup(sender: AnyObject)
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
        return classes.count + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        if indexPath.row == 0
        {
            var cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
            cell.textLabel?.text = "All Students"
            cell.backgroundColor = UIColor(red: 50, green: 50, blue: 50, alpha: 0.5)
            
            let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.view.frame.size.width, 90))
            
            whiteRoundedView.layer.backgroundColor = UIColor(red: 70, green: 70, blue: 70, alpha: 0.5).CGColor
            whiteRoundedView.layer.masksToBounds = false
            whiteRoundedView.layer.cornerRadius = 2.0
            whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
            whiteRoundedView.layer.shadowOpacity = 0.2
            
            cell.contentView.addSubview(whiteRoundedView)
            cell.contentView.sendSubviewToBack(whiteRoundedView)
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier("groupCell") as! groupTableCell
        cell.layer.borderColor = UIColor.whiteColor().CGColor
        cell.groupName.text = classes[indexPath.row-1]
        
        cell.averageStepsLabel.text = "\(getAverageForGroup(classes[indexPath.row-1]))"
        cell.backgroundColor = UIColor(red: 50, green: 50, blue: 50, alpha: 0.5)
        
        let whiteRoundedView : UIView = UIView(frame: CGRectMake(0, 10, self.view.frame.size.width, 90))
        
        whiteRoundedView.layer.backgroundColor = UIColor(red: 70, green: 70, blue: 70, alpha: 0.5).CGColor
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 2.0
        whiteRoundedView.layer.shadowOffset = CGSizeMake(-1, 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubviewToBack(whiteRoundedView)
        
        return cell
        
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0
        {
            performSegueWithIdentifier("allStudents", sender: self)
            return
        }
        
        sendingClassName = classes[indexPath.row-1]
        
    
    
        performSegueWithIdentifier("specific", sender: self)
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        var temp: [UITableViewRowAction] = []
        
        let remove = UITableViewRowAction(style: .Default, title: "Remove Group") { (action, path) in
            
            tableView.beginUpdates()
            
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! groupTableCell
            let titleText = cell.groupName.text!
            
            let loc = self.classes.indexOf(titleText)
            
            if loc != nil
            {
                self.classes.removeAtIndex(loc!)
            }
            
            self.defaults.setObject(self.classes, forKey: "classes")
            
            var friendsLoc = self.friendClasses.indexOf(titleText)
            
            while friendsLoc != nil
            {
                self.friendClasses.removeAtIndex(friendsLoc!)
                self.friendClasses.insert(" ", atIndex: friendsLoc!)
                friendsLoc = self.friendClasses.indexOf(titleText)
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
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return UIModalPresentationStyle.None
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showSettings1"
        {
            let popvc = segue.destinationViewController
            popvc.popoverPresentationController?.delegate = self
        }
        if segue.identifier == "specific"
        {
            
            let next = segue.destinationViewController as! specificClassViewController
            
            next.className = sendingClassName
            next.parameters = self.parameters
            next.oauthswift = self.oauthswift
            next.headers = self.headers
        }
        if segue.identifier == "allStudents"
        {
            let next = segue.destinationViewController as! ViewController
            next.parameters = self.parameters
            next.oauthswift = self.oauthswift
            next.headers = self.headers
        }
    }
    
    func getAverageForGroup(group : String) -> Int
    {
        var average: Int = 0
        var number : Int = 0
        if group == "all"
        {
            for (key, value1) in friendDict
            {
                for i in value1
                {
                    if Int(i.objectForKey("value") as! String)! != 0
                    {
                        average = Int(i.objectForKey("value") as! String)! + average
                        number++
                    }
                }
            }
            
            if number != 0
            {
                average = average / number
            }
            
        }
        else
        {
            var indexes : [Int] = []
            for i in 0..<friendClasses.count
            {
                if friendClasses[i] == group
                {
                    indexes.append(i)
                }
            }
            
            var friends : [String] = []
            for index in indexes
            {
                friends.append((savedFriends)[index])
            }
            
            for friend in friends
            {
                if friendDict[friend] != nil
                {
                    for i in friendDict[friend]!
                    {
                        if Int(i.objectForKey("value") as! String)! != 0
                        {
                            
                            average = Int(i.objectForKey("value") as! String)! + average
                            number+=1
                        }
                    }
                }
            }
            
            if number != 0
            {
                average = average / number
            }
            
        }
        return average
        
    }
    
    
    
}