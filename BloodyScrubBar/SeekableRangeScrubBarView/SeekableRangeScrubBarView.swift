import UIKit

class SeekableRangeScrubBarView: UIView {

    @IBOutlet private weak var contentView: UIView!
    @IBOutlet private weak var disabledSlider: UISlider!
    @IBOutlet private weak var activeSlider: UISlider!
    @IBOutlet private weak var activeSliderTrailingConstraint: NSLayoutConstraint!
    @IBOutlet private weak var activeSliderLeadingConstraint: NSLayoutConstraint!

    private(set) lazy var lightFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    private(set) lazy var mediumFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    weak var delegate: SeekableRangeScrubBarViewDelegate?

    var value: Float {
        return activeSlider.value
    }

    var accessibilityStep: Float {
        return activeSlider.maximumValue / 20
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let bundle = Bundle(for: SeekableRangeScrubBarView.self)
        bundle.loadNibNamed("SeekableRangeScrubBarView", owner: self)
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([contentView.topAnchor.constraint(equalTo: topAnchor),
                                     contentView.bottomAnchor.constraint(equalTo: bottomAnchor) ,
                                     contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
                                     contentView.trailingAnchor.constraint(equalTo: trailingAnchor)])
        setupScrubBar()
    }

    func applyTheme(elapsedProgressColor: UIColor,
                    remainingProgressColor: UIColor,
                    unseekableColor: UIColor) {
        activeSlider.setThumbImage(thumbImage(forSize: CGSize(width: 12, height: 12), tint: elapsedProgressColor), for: .normal)
        activeSlider.minimumTrackTintColor = elapsedProgressColor
        activeSlider.maximumTrackTintColor = remainingProgressColor
        contentView.backgroundColor = .clear
        disabledSlider.minimumTrackTintColor = unseekableColor
        disabledSlider.maximumTrackTintColor = unseekableColor
        disabledSlider.setThumbImage(thumbImage(forSize: CGSize(width: 1, height: 1), tint: .clear), for: .normal)
    }

    func positionOfThumb(in parentView: UIView) -> CGPoint {
        let thumbRect = activeSlider.thumbRect(forBounds: activeSlider.bounds, trackRect: activeSlider.trackRect(forBounds: activeSlider.bounds), value: activeSlider.value)
        let handleCenter = CGPoint(x: thumbRect.midX, y: thumbRect.midY)
        return activeSlider.convert(handleCenter, to: parentView)
    }

    private func setupScrubBar() {
        activeSlider.value = 0
        activeSlider.isContinuous = true
    }

    private func thumbImage(forSize size: CGSize, tint: UIColor?) -> UIImage? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        view.backgroundColor = tint
        view.layer.cornerRadius = view.frame.size.width / 2

        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        defer { UIGraphicsEndImageContext() }
        if let context = UIGraphicsGetCurrentContext() {
            view.layer.render(in: context)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            return image
        }
        return nil
    }
}

// MARK: - Update Dimensions
extension SeekableRangeScrubBarView {
    func update(scrubBarMin: Float) {
        activeSlider.minimumValue = scrubBarMin
    }

    func update(scrubBarMax: Float) {
        activeSlider.maximumValue = scrubBarMax
    }

    func update(scrubBarProgress: Float) {
        activeSlider.setValue(scrubBarProgress, animated: true)
    }

    func updateLeadingConstraint(proportionOfTotalWidth: Double) {
        activeSliderLeadingConstraint.constant = -proportionOfTotalWidth * frame.width
        UIView.animate(withDuration: 0.05, delay: 0) {
            self.layoutIfNeeded()
        }
    }

    func updateTrailingConstraint(proportionOfTotalWidth: Double) {
        activeSliderTrailingConstraint.constant = proportionOfTotalWidth * frame.width
        UIView.animate(withDuration: 0.05, delay: 0) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Actions
extension SeekableRangeScrubBarView {
    @IBAction func scrubBarTouchDown(_ sender: UISlider) {
        lightFeedbackGenerator.impactOccurred()
        mediumFeedbackGenerator.prepare()

        activeSlider.setThumbImage(thumbImage(forSize: CGSize(width: 20, height: 20), tint: activeSlider.minimumTrackTintColor), for: .normal)

        delegate?.rangedScrubBarDidStartScrubbing()
    }

    @IBAction func scrubBarTouchUp(_ scrubBar: UISlider) {
        mediumFeedbackGenerator.impactOccurred()

        activeSlider.setThumbImage(thumbImage(forSize: CGSize(width: 12, height: 12), tint: activeSlider.minimumTrackTintColor), for: .normal)

        delegate?.rangedScrubBarDidEndScrubbing(at: activeSlider.value)
    }

    @IBAction func scrubBarValueChanged(_ scrubBar: UISlider) {
        delegate?.rangedScrubBarDidMove(to: scrubBar.value)
    }
}

// MARK: - Delegate
protocol SeekableRangeScrubBarViewDelegate: AnyObject {
    func rangedScrubBarDidEndScrubbing(at value: Float)
    func rangedScrubBarDidStartScrubbing()
    func rangedScrubBarDidMove(to value: Float)
}
