//
//  OnboardingViewController.swift
//  InternetShopKeeper
//
//  Created by Oleksandr Solokha on 08.04.2020.
//  Copyright © 2020 Oleksandr Solokha. All rights reserved.
//

import UIKit

protocol OnboardingViewControllerDelegate {
    func openPage(with index: Int)
}

class OnboardingViewController: UIViewController {
    
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipTutorialButton: UIButton!

    open var delegate: OnboardingViewControllerDelegate?
    //create array of ModelFirstLaunch
    private let modelFirstLaunch: [ModelFirstLaunch] = [
        ModelFirstLaunch(imageName: "Santa3", title: "Run with Santa!".localized, subtitle: "Santa is running on South Pole. Help to Santa run as far away as you can.".localized),
        ModelFirstLaunch(imageName: "candy", title: "Pick up candies!".localized, subtitle: "Help to Santa to pick up so much candies that take to you extra points.".localized),
        ModelFirstLaunch(imageName: "water", title: "Jump above water!".localized, subtitle: "Santa must jump above water that he can  run more further away.".localized)
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        pageControl.numberOfPages = modelFirstLaunch.count
        skipTutorialButton.setTitle("Skip".localized, for: .normal)
    }
    // configure segue to FirstLaunchPageViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "ToPageVC":
            guard let controller = segue.destination as? FirstLaunchPageViewController else { return }
            delegate = controller
            controller.onboardingDelegate = self
            let controllers = modelFirstLaunch.compactMap { model -> UIViewController? in
                guard let controller = storyboard?.instantiateViewController(withIdentifier: "FirstLaunchViewController") as? FirstLaunchViewController else { return nil }
                _ = controller.view
                controller.setupWhitModel(model: model)
                return controller
            }
            controller.setControllers(controllers: controllers)
        default: break
        }
    }
    // configure button skip
    @IBAction func skipTutorialAction(_ sender: UIButton) {
        // configure button to skip tutorial
        UserDefaults.standard.set(true, forKey: "onboarding")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let VC = storyboard?.instantiateViewController(identifier: "MainGameViewController")
        appDelegate.window?.rootViewController = VC
    }
    // configure UIPageControl
    @IBAction func pageControllerAction(_ sender: UIPageControl) {
        delegate?.openPage(with: sender.currentPage)
    }
}

extension OnboardingViewController: FirstLaunchPageViewControllerDelegate {
    func indexIsChanged(index: Int) {
        pageControl.currentPage = index
    }
}
