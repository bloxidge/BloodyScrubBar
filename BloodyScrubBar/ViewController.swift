import UIKit

class ViewController: UIViewController {

    @IBOutlet var leadingSlider: UISlider!
    @IBOutlet var leadingTextField: UITextField!
    @IBOutlet var trailingSlider: UISlider!
    @IBOutlet var trailingTextField: UITextField!

    @IBOutlet var valueLabel: UILabel!

    @IBOutlet var leadingLabel: UILabel!
    @IBOutlet var trailingLabel: UILabel!
    @IBOutlet var scrubBar: SeekableRangeScrubBarView!

    private let startTime: TimeInterval = 0
    private let endTime: TimeInterval = 60*60

    override func viewDidLoad() {
        super.viewDidLoad()

        leadingLabel.text = startTime.string
        trailingLabel.text = endTime.string

        scrubBar.applyTheme(elapsedProgressColor: UIColor(red: 1, green: 0.298, blue: 0.596, alpha: 0.5),
                            remainingProgressColor: UIColor(white: 1.0, alpha: 0.3),
                            unseekableColor: UIColor(white: 0.7, alpha: 0.3))
        scrubBar.delegate = self
    }

    // MARK: Leading inactive proportion

    @IBAction func leadingTextEntered(_ sender: UITextField) {
        if let text = sender.text, let value = try? Float(text, format: .number) {
            leadingSlider.value = value
            scrubBar.updateLeadingConstraint(proportionOfTotalWidth: Double(value))
        }
    }

    @IBAction func leadingSliderValueChanged(_ sender: UISlider) {
        leadingTextField.text = String(format: "%0.3f", sender.value)
        scrubBar.updateLeadingConstraint(proportionOfTotalWidth: Double(sender.value))
    }

    // MARK: Trailing inactive proportion

    @IBAction func trailingTextEntered(_ sender: UITextField) {
        if let text = sender.text, let value = try? Float(text, format: .number) {
            let invertedValue = trailingSlider.maximumValue - value
            trailingSlider.value = invertedValue
            scrubBar.updateTrailingConstraint(proportionOfTotalWidth: Double(invertedValue))
        }
    }

    @IBAction func trailingSliderValueChanged(_ sender: UISlider) {
        let invertedValue = trailingSlider.maximumValue - sender.value
        trailingTextField.text = String(format: "%0.3f", invertedValue)
        scrubBar.updateTrailingConstraint(proportionOfTotalWidth: Double(invertedValue))
    }
}

extension ViewController: SeekableRangeScrubBarViewDelegate {
    func rangedScrubBarDidEndScrubbing(at value: Float) {
        let totalTime = endTime - startTime
        let currentTime = (TimeInterval(value) * totalTime) + startTime
        leadingLabel.text = currentTime.string
    }

    func rangedScrubBarDidStartScrubbing() {
    }

    func rangedScrubBarDidMove(to value: Float) {
        valueLabel.text = String(format: "%0.6f", value)
    }
}

extension TimeInterval {
    var string: String {
        let interval = Int(floor(self))
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        if hours > 0 {
            return String(format: "%d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}
