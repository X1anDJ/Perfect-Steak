//
//  InstructionsViewController.swift
//  PerfectSteak
//

import UIKit

final class InstructionsViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "使用说明"
        view.backgroundColor = UIColor(red: 0.262, green: 0.262, blue: 0.262, alpha: 1)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(dismissInstructions))
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
            "这是一款牛排烘培时间计算器。使用先煎后烤的方法时，可以计算烤箱所需烘培时间，制作内部熟度均匀一致的牛排。",
            font: .systemFont(ofSize: 17),
            color: .white
        )

        addSection(
            title: "先煎后烤的原理：",
            body: "煎：快速加热过程。牛排外壳快速升温，同时不影响内部熟度。\n\n烤：缓慢加热过程。牛排内部缓慢升温至目标温度（熟度），达到内部熟度分布均匀，低温慢煮的效果。",
            emphasizedPhrases: ["煎：", "烤："]
        )

        addSection(
            title: "使用步骤：",
            body: "1. 350°F/176°C 预热烤箱¹。\n2. 用最大火²热锅，将牛排煎至上色。\n3. 将牛排从锅中取出，测量牛排的中心温度³/厚度。\n4. 将目标熟度/烤箱温度/牛排的中心温度/牛排厚度输入 App，计算所需烘培时间。\n5. 享用⁴。",
            emphasizedPhrases: ["1.", "2.", "3.", "4.", "5.", "350°F/176°C", "目标熟度", "烤箱温度", "中心温度", "牛排厚度"]
        )

        addSeparator()

        addSection(
            title: "注释：",
            body: "1. 烤箱预热可以使用更低的温度。烤箱温度越低，升温过程约缓慢，肉质熟度越均匀。\n\n2. 煎制时的火越大越好。专业流程甚至让明火直接接触牛排。\n\n3. 如果没有测温针：如果没有解冻，就输入冰箱的温度。如果有解冻，就输入室温。\n\n4. 此流程无需 rest，因为烤的时候内外温差小，肌肉纤维收缩柔和。最终效果很大取决于烤箱温度是否准确。",
            emphasizedPhrases: ["1.", "2.", "3.", "4.", "没有测温针", "无需 rest"]
        )
    }

    private func addSection(title: String, body: String, emphasizedPhrases: [String] = []) {
        addLabel(title, font: .boldSystemFont(ofSize: 20), color: UIColor(red: 1, green: 0.365, blue: 0.196, alpha: 1))
        addLabel(body, font: .systemFont(ofSize: 16), color: .white, emphasizedPhrases: emphasizedPhrases)
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
