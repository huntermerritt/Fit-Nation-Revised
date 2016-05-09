import UIKit
import Charts
class studentViewController: UIViewController, ChartViewDelegate
{
    
    
    @IBOutlet weak var showMinutesView: UIButton!
    @IBOutlet weak var showStepsView: UIButton!
    @IBOutlet weak var gradeScoreLabel: UILabel!
    @IBOutlet weak var barChartView: BarChartView!
    var stepValues : [Double] = [1000,2000,3000,2000]
    var dates : [String] = ["10-24-2016", "10-25-2016", "10-26-2016", "10-27-2016"]
    
    override func viewDidLoad()
    {
        barChartView.delegate = self
        barChartView.backgroundColor = UIColor.clearColor()
        
        gradeScoreLabel.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        showMinutesView.layer.cornerRadius = 8
        showMinutesView.clipsToBounds = true
        showMinutesView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        
        showStepsView.backgroundColor = UIColor(red: 255, green: 255, blue: 255, alpha: 0.3)
        showStepsView.layer.cornerRadius = 8
        showStepsView.clipsToBounds = true
        
        setChart(dates, values: stepValues)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        
    }
    
    func setChart(dataPoints: [String], values: [Double]) {
        barChartView.noDataText = ""
        
        var dataEntries: [BarChartDataEntry] = []
        
        for i in 0..<dataPoints.count {
            let dataEntry = BarChartDataEntry(value: values[i], xIndex: i)
            dataEntries.append(dataEntry)
        }
        
        let chartDataSet = BarChartDataSet(yVals: dataEntries, label: "")
        let chartData = BarChartData(xVals: dates, dataSet: chartDataSet)
        
        
        barChartView.descriptionText = ""
        
        chartDataSet.colors = []
        for i in 0..<values.count
        {
            if values[i] >= 3000
            {
                chartDataSet.colors.append(UIColor.greenColor())
            }
            else if values[i] >= 2000
            {
                chartDataSet.colors.append(UIColor.orangeColor())
            }
            else
            {
                chartDataSet.colors.append(UIColor.redColor())
            }
        }
        
        barChartView.data = chartData
        barChartView.xAxis.labelPosition = .Bottom

        barChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .EaseInBounce)
        
        let ll = ChartLimitLine(limit: 3000, label: "Target")
        barChartView.rightAxis.addLimitLine(ll)
        
    }
    
}
