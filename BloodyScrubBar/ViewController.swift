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

    override func viewDidLoad() {
        super.viewDidLoad()

        let iPlayerPink = UIColor(red: 1, green: 0.298, blue: 0.596, alpha: 0.5)
        scrubBar.applyTheme(elapsedProgressColor: iPlayerPink,
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
    }

    func rangedScrubBarDidStartScrubbing() {
    }

    func rangedScrubBarDidMove(to value: Float) {
        valueLabel.text = String(format: "%0.6f", value)
    }
}
