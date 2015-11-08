//
//  ViewController.swift
//  Custom Money
//
//  Created by Daniel Thorpe on 04/11/2015.
//  Copyright © 2015 Daniel Thorpe. All rights reserved.
//

import UIKit
import Money

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let hearts: Hearts = 8.7
        let bees: Bees = 3.4

        print("You have \(hearts) and \(bees)")

        let total = Bank<Hearts,Bees>.fx(hearts).counter + bees

        print("Exchanging your \(hearts) into \(Currency.Bee.symbol) via the bank gives you \(total) in total.")
    }
}

