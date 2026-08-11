//
//  InstructionsViewController.swift
//  PerfectSteak
//

import UIKit

final class InstructionsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    private let appOrange = UIColor(red: 1, green: 0.365, blue: 0.196, alpha: 1)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = L("Instructions Title")
        view.backgroundColor = UIColor(red: 0.262, green: 0.262, blue: 0.262, alpha: 1)
        setupDoneButton()
        setupNavigationBarAppearance()
        setupViews()
        addInstructionContent()
    }

    private func setupDoneButton() {
        if #available(iOS 26.0, *) {
            var configuration = UIButton.Configuration.glass()
            configuration.title = L("Done")
            configuration.baseForegroundColor = .white

            let doneButton = UIButton(configuration: configuration, primaryAction: UIAction { [weak self] _ in
                self?.dismissInstructions()
            })
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
            return
        }

        let doneButton = UIButton(type: .system)
        doneButton.setTitle(L("Done"), for: .normal)
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.titleLabel?.font = .boldSystemFont(ofSize: 15)
        doneButton.backgroundColor = UIColor(white: 0.30, alpha: 1)
        doneButton.layer.cornerRadius = 18
        doneButton.layer.masksToBounds = true
        doneButton.addTarget(self, action: #selector(dismissInstructions), for: .touchUpInside)
        doneButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            doneButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 64),
            doneButton.heightAnchor.constraint(equalToConstant: 36)
        ])

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: doneButton)
    }

    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.262, green: 0.262, blue: 0.262, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance

        if #unavailable(iOS 26.0) {
            navigationController?.navigationBar.tintColor = .white
        }
    }

    private func setupViews() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 24),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.leadingAnchor, constant: 24),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.frameLayoutGuide.trailingAnchor, constant: -24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32)
        ])
    }

    private func addInstructionContent() {
        addLabel(
            L("Instructions Intro"),
            font: .systemFont(ofSize: 17),
            color: .white
        )

        addSection(
            title: L("Instructions Principle Title"),
            body: L("Instructions Principle Body"),
            emphasizedPhrases: localizedList("Instructions Principle Emphasis")
        )

        addStepsSection(
            title: L("Instructions Steps Title"),
            body: L("Instructions Steps Body"),
            emphasizedPhrases: localizedList("Instructions Steps Emphasis")
        )

        addSeparator()

        addSection(
            title: L("Instructions Notes Title"),
            body: L("Instructions Notes Body"),
            emphasizedPhrases: localizedList("Instructions Notes Emphasis")
        )
    }

    private func addSection(title: String, body: String, emphasizedPhrases: [String] = []) {
        addLabel(title, font: .boldSystemFont(ofSize: 20), color: .white)
        addLabel(body, font: .systemFont(ofSize: 16), color: .white, emphasizedPhrases: emphasizedPhrases)
    }

    private func addStepsSection(title: String, body: String, emphasizedPhrases: [String]) {
        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 16
        container.layoutMargins = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        container.isLayoutMarginsRelativeArrangement = true
        container.backgroundColor = UIColor(white: 0.18, alpha: 1)
        container.layer.cornerRadius = 8
        container.layer.borderWidth = 1
        container.layer.borderColor = appOrange.withAlphaComponent(0.35).cgColor
        contentStackView.addArrangedSubview(container)

        let titleLabel = makeLabel(title, font: .boldSystemFont(ofSize: 22), color: appOrange)
        container.addArrangedSubview(titleLabel)

        let stepPhrases = emphasizedPhrases.filter { !isStepNumberPhrase($0) }
        for step in parsedSteps(from: body) {
            container.addArrangedSubview(makeStepRow(number: step.number, text: step.text, emphasizedPhrases: stepPhrases))
        }
    }

    private func parsedSteps(from body: String) -> [(number: String, text: String)] {
        body.split(separator: "\n").map(String.init).compactMap { line in
            guard let separatorRange = line.range(of: ". ") else {
                return nil
            }

            let number = String(line[..<separatorRange.lowerBound])
            let text = String(line[separatorRange.upperBound...])
            return (number, text)
        }
    }

    private func makeStepRow(number: String, text: String, emphasizedPhrases: [String]) -> UIView {
        let row = UIView()

        let numberLabel = UILabel()
        numberLabel.text = number
        numberLabel.textAlignment = .center
        numberLabel.font = .boldSystemFont(ofSize: 15)
        numberLabel.textColor = .white
        numberLabel.backgroundColor = appOrange
        numberLabel.layer.cornerRadius = 14
        numberLabel.layer.masksToBounds = true
        numberLabel.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(numberLabel)

        let bodyLabel = makeLabel(text, font: .systemFont(ofSize: 16), color: .white, emphasizedPhrases: emphasizedPhrases)
        bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        row.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            numberLabel.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            numberLabel.widthAnchor.constraint(equalToConstant: 28),
            numberLabel.heightAnchor.constraint(equalToConstant: 28),
            numberLabel.centerYAnchor.constraint(equalTo: bodyLabel.firstBaselineAnchor, constant: -7),

            bodyLabel.topAnchor.constraint(equalTo: row.topAnchor),
            bodyLabel.leadingAnchor.constraint(equalTo: numberLabel.trailingAnchor, constant: 16),
            bodyLabel.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: row.bottomAnchor)
        ])

        return row
    }

    private func isStepNumberPhrase(_ phrase: String) -> Bool {
        phrase.count == 2 && phrase.last == "." && phrase.first?.isNumber == true
    }

    private func localizedList(_ key: String) -> [String] {
        L(key).split(separator: "|").map(String.init)
    }

    private func addSeparator() {
        let separator = UIView()
        separator.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        separator.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.addArrangedSubview(separator)
        separator.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }

    private func addLabel(_ text: String, font: UIFont, color: UIColor, emphasizedPhrases: [String] = []) {
        contentStackView.addArrangedSubview(makeLabel(text, font: font, color: color, emphasizedPhrases: emphasizedPhrases))
    }

    private func makeLabel(_ text: String, font: UIFont, color: UIColor, emphasizedPhrases: [String] = []) -> UILabel {
        let label = UILabel()
        label.attributedText = attributedText(text, font: font, color: color, emphasizedPhrases: emphasizedPhrases)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }

    private func attributedText(_ text: String, font: UIFont, color: UIColor, emphasizedPhrases: [String]) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.paragraphSpacing = 6

        let attributedString = NSMutableAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle
            ]
        )

        let boldFont = UIFont.boldSystemFont(ofSize: font.pointSize)
        for phrase in emphasizedPhrases {
            let range = (text as NSString).range(of: phrase)
            if range.location != NSNotFound {
                attributedString.addAttribute(.font, value: boldFont, range: range)
            }
        }

        return attributedString
    }

    @objc private func dismissInstructions() {
        dismiss(animated: true)
    }
}
