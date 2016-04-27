import UIKit
class Settings: UIViewController
{
    @IBOutlet weak var steps: UITextField!
    let defaults = NSUserDefaults()
    
    @IBAction func saveButtonPressed(sender: AnyObject)
    {
        if steps.text != ""
        {
            if let numSteps = Int(steps.text!)
            {
                print("saved")
                self.defaults.setObject((Int)(steps.text!), forKey: "grade")
                self.dismissViewControllerAnimated(false, completion: nil)
            }
            else
            {
                print("error")
            }
            
        }
    }
    
}