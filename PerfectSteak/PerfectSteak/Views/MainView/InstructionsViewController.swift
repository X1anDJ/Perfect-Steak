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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: L("Done"), style: .done, target: self, action: #selector(dismissInstructions))
        navigationItem.rightBarButtonItem?.tintColor = UIColor(white: 0.18, alpha: 1)
        setupViews()
        addInstructionContent()
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

        addSection(
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
        addLabel(title, font: .boldSystemFont(ofSize: 20), color: UIColor(red: 1, green: 0.365, blue: 0.196, alpha: 1))
        addLabel(body, font: .systemFont(ofSize: 16), color: .white, emphasizedPhrases: emphasizedPhrases)
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
        let label = UILabel()
        label.attributedText = attributedText(text, font: font, color: color, emphasizedPhrases: emphasizedPhrases)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        contentStackView.addArrangedSubview(label)
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
