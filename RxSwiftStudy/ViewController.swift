//
//  ViewController.swift
//  RxSwiftStudy
//
//  Created by Popeye Lau on 16/5/30.
//  Copyright © 2016年 FavourFree. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UIViewController {

    @IBOutlet weak var userNameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var bottomLineView: UIView!
    @IBOutlet weak var bottomLineWidthConstraint: NSLayoutConstraint!

    var disposeBag: DisposeBag! = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()


        userNameField.layer.borderWidth = 1.0
        passwordField.layer.borderWidth = 1.0

        let userNameObservable = userNameField.rx_text.map { $0.characters.count >= 6 }
        let passwordObservable = passwordField.rx_text.map { $0.characters.count >= 6 }

        userNameObservable.map { $0 ? UIColor.greenColor() : UIColor.clearColor() }
            .subscribeNext { [weak self] in
                self?.userNameField.layer.borderColor = $0.CGColor
        }.addDisposableTo(disposeBag)

        passwordObservable.map { $0 ? UIColor.greenColor() : UIColor.clearColor() }
            .subscribeNext { [weak self] in
                self?.passwordField.layer.borderColor = $0.CGColor
        }.addDisposableTo(disposeBag)

        Observable.combineLatest(userNameObservable, passwordObservable) { $0 && $1 }
            .bindTo(signinButton.rx_enabled)
            .addDisposableTo(disposeBag)


        // Amimations
        let textFieldTransfrom = CGAffineTransformMakeTranslation(0, -200)
        let buttonTransform = CGAffineTransformMakeTranslation(-200, 0)
        userNameField.transform = textFieldTransfrom
        passwordField.transform = textFieldTransfrom
        signinButton.transform = buttonTransform
        bottomLineWidthConstraint.constant = 0.0
        self.view.layoutIfNeeded()

        /*
        let str:String? = "201605200010"
        print(str.isNone ? "-" : "订单号:\(str!)")
        print(str.maybe("-", f: { "订单号:\($0)" }))*/

    }




    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        ViewControllerAmimationUitl.textFieldAnimation(userNameField)
        ViewControllerAmimationUitl.textFieldAnimation(passwordField)
        ViewControllerAmimationUitl.buttonAnimation(signinButton)
        ViewControllerAmimationUitl.bottomLineAnimationWithConstraint(bottomLineWidthConstraint,view: view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}




class ViewControllerAmimationUitl {

    static let defaultWidth:CGFloat = 345.0

    class func textFieldAnimation(textField:UITextField) {
        UIView.animateWithDuration(1.0) {
            textField.transform = CGAffineTransformIdentity
        }
    }

    class func buttonAnimation(button:UIButton) {
        UIView.animateWithDuration(1.0) {
            button.transform = CGAffineTransformIdentity
        }
    }

    class func bottomLineAnimationWithConstraint(constraint:NSLayoutConstraint,view:UIView) {
        UIView.animateWithDuration(1.0) {
            constraint.constant = defaultWidth
            view.layoutIfNeeded()
        }
    }
}
