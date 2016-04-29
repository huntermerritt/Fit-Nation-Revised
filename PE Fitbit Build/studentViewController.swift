import UIKit
class studentViewController: UIViewController
{
    
    
    @IBOutlet weak var showMinutesView: UIButton!
    @IBOutlet weak var showStepsView: UIButton!
    @IBOutlet weak var gradeScoreLabel: UILabel!
    
    override func viewDidLoad()
    {
        gradeScoreLabel.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        showMinutesView.layer.cornerRadius = 8
        showMinutesView.clipsToBounds = true
        showMinutesView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        
        showStepsView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        showStepsView.layer.cornerRadius = 8
        showStepsView.clipsToBounds = true
    }
    
    override func viewDidAppear(animated: Bool)
    {
        
    }
}