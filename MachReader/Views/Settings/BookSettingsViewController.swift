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
    @IBOutlet private weak var bookRemoveView: UIView!
    @IBOutlet private weak var activityPrivacyView: UIView!
    
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

        // TODO: this function
        activityPrivacyView.isHidden = true
        
        setupNavigationBar()
        setupSwitch()
    }
    
    // MARK: - private methods
    
    private func setupNavigationBar() {
        title = "Setting"
        let backButtonItem = UIBarButtonItem(image: UIImage(named: "ic_close"), style: .plain, target: self, action: #selector(handleCancelAction(_:)))
        navigationItem.leftBarButtonItem = backButtonItem
    }
    
    private func setupSwitch() {
        othersHighlightSwitch.isOn = !UserDefaultsUtil.showOthersHighlight
        activityPrivateSwitch.isOn = UserDefaultsUtil.isPrivateActivity
        bookPrivateSwitch.isOn = viewModel.isBookPublic
        
        // not display these views when a book is not mine.
        bookPrivateView.isHidden = !viewModel.isBookMine
        bookRemoveView.isHidden = !viewModel.isBookMine
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
        viewModel.changeBookOpenScope(isPublic: sender.isOn)
    }
    
    @IBAction func handleRemoveBookButton(_ sender: Any) {
        let alert = AlertController(title: "本の削除", message: "本当に本を削除しますか？", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel)
        let removeAction = UIAlertAction(title: "削除", style: .destructive) { [weak self] action in
            self?.viewModel.removeBook()
            let prevVC = self?.presentingViewController as! UINavigationController
            self?.dismiss(animated: true) {
                prevVC.popToRootViewController(animated: true)
            }
        }
        alert.addAction(removeAction)
        alert.addAction(cancelAction)
        alert.show()
    }
}
