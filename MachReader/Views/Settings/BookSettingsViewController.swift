//
//  BookSettingsViewController.swift
//  MachReader
//
//  Created by ShuichiNagao on 2018/06/22.
//  Copyright © 2018 mach-technologies. All rights reserved.
//

import UIKit

class BookSettingsViewController: UIViewController {

    @IBOutlet private weak var bookPrivateView: UIView!
    @IBOutlet private weak var othersHighlightSwitch: UISwitch!
    @IBOutlet private weak var activityPrivateSwitch: UISwitch!
    @IBOutlet private weak var bookPrivateSwitch: UISwitch!
    
    private var viewModel: BookSettingsViewModel!
    
    static func instantiate(book: Book) -> BookSettingsViewController {
        let sb = UIStoryboard(name: "BookSettings", bundle: nil)
        let vc = sb.instantiateInitialViewController() as! BookSettingsViewController
        let vm = BookSettingsViewModel(book: book)
        vc.viewModel = vm
        return vc
    }
    
    // MARK: - lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupNavigationBar()
        setupSwitch()
    }
    
    // MARK: - private methods
    
    private func setupNavigationBar() {
        title = "Setting"
        // UIBarButtonItem(image: closeImage, style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        let backButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    private func setupSwitch() {
        othersHighlightSwitch.isOn = !UserDefaultsUtil.showOthersHighlight
        activityPrivateSwitch.isOn = UserDefaultsUtil.isPrivateActivity
        bookPrivateSwitch.isOn = viewModel.isBookPublic
        bookPrivateView.isHidden = viewModel.shouldHideBookPrivacyView
    }
    

    @objc private func handleCancelAction(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction private func handleOthersHighlightSwitch(_ sender: UISwitch) {
        viewModel.showOthersHighlight(isOn: !sender.isOn)
    }
    
    @IBAction func handleActivityPrivateSwitch(_ sender: UISwitch) {
        viewModel.changeActivityPrivacy(isPrivate: sender.isOn)
    }
    
    @IBAction func handleBookPrivateSwitch(_ sender: UISwitch) {
        viewModel.changeBookOpenScope(isPublic: !sender.isOn)
    }
    
}
