import UIKit
import OAuthSwift
import Charts

// temp
//master commit

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
    
    override func viewDidLoad()
    {
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
        if defaults.arrayForKey("friendClasses") != nil
        {
            friendClasses = defaults.arrayForKey("friendClasses") as! [String]
        }
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = UIColor(red: 50, green: 50, blue: 50, alpha: 0.5)
        
        let step = ["Steps", "Steps left"]
        let stepTotal = [8080.0, 1920]
        setChart(step, values: stepTotal)
    }
    
    override func viewDidAppear(animated: Bool) {
        pieChart.animate(xAxisDuration: 3, yAxisDuration: 3, easingOption: ChartEasingOption.EaseInBounce)
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
        cell.groupName.text = classes[indexPath.row - 1]
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
        
        sendingClassName = classes[indexPath.row - 1]
        
    
    
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
    
    
    
}