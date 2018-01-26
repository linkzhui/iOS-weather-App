//
//  CityPageViewController.swift
//  Lab3_Weather
//
//  Created by Jerry Lee on 12/9/17.
//  Copyright © 2017 Jerry Lee. All rights reserved.
//

import UIKit

class CityPageViewController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    
    lazy var VCArray : [UIViewController] = {
        return [self.VCInstance(name: "CurrrentCityVC")]
    }()
    
    private func VCInstance (name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        // Do any additional setup after loading the view.
        if let firstVC = VCArray.first {
            setViewControllers([firstVC], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews {
            if view is UIScrollView {
                view.frame = UIScreen.main.bounds
            } else if view is UIPageControl{
                view.backgroundColor = UIColor.clear
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArray.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        guard previousIndex >= 0 else {
            return nil
        }
        guard VCArray.count > previousIndex else {
            return nil
        }
        return VCArray[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let viewControllerIndex = VCArray.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        guard nextIndex < VCArray.count else {
            return nil
        }
        guard VCArray.count > nextIndex else {
            return nil
        }
        return VCArray[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return VCArray.count
    }
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        guard let firstVC = viewControllers?.first, let firstVCIndex = VCArray.index(of: firstVC) else {
            return 0
        }
        return firstVCIndex
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
