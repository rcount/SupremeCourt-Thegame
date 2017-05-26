//
//  ScoreStoryBoardViewController.swift
//  ProofOfConcept
//
//  Created by Stephen Vickers on 2/15/17.
//  Copyright © 2017 Stephen Vickers. All rights reserved.
//

import UIKit

class ScoreViewController: UIViewController {

    //MARK -- Standard variables used in this class


    //variable to hold the score that the student got
    var score = 0

    //variable to hold the total of the number of questions the student was presented with
    var total = 0

    var missedQuestions = [Question]()

    //MARK - IBOutlets used in this class -

    //out let for the scoreLabel for the view
    @IBOutlet weak var scoreLabelOutlet: UILabel!

    @IBOutlet weak var missedQuestionsTableView: UITableView!
    
    @IBOutlet weak var scoreCardOutlet: UIView!
    
    //MARK - Override of the UIViewController methods we need for this class -

    //Override of the viewDidLoad so we can set the properties of the view before it shows
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scoreCardOutlet.center = self.view.center

        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidRotate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        //set the self.scoreLabelOutlet to show the score out of the number correct
        self.scoreLabelOutlet.text = "Your score is \(self.score) out of \(self.total)"

        //set the tableView datasourse and delegate
        self.missedQuestionsTableView.dataSource = self
        self.missedQuestionsTableView.delegate = self
        
        //set the height of the rows to scale automaticily and set the extimated Row Height
        self.missedQuestionsTableView.rowHeight = UITableViewAutomaticDimension
        self.missedQuestionsTableView.estimatedRowHeight = 50
        
        //set the tableFooterView to a UIView with the size of zero
        //makes it to where there are no empty frames under the view.
        self.missedQuestionsTableView.tableFooterView = UIView(frame: .zero)

        //if there are no missed questions hide the tableView
        if self.missedQuestions.isEmpty{
            self.missedQuestionsTableView.alpha = 0
        }
        
    }


    //MARK - IBActions for this class -

    //TouchUpInside action for the redoButton on the view
    //if it's touched we dismiss the view and back up one
    //in this case to the MainViewController which is the questionView
    //param     sender for the attached UIDesignableButton
    @IBAction func redoButtonAction(_ sender: UIDesignableButton) {
        self.dismiss(animated: true)
    }
    
    @objc private func viewDidRotate(_ notification: NSNotification){
        self.scoreCardOutlet.center = self.view.center
    }

}

extension ScoreViewController: UITableViewDataSource, UITableViewDelegate {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.missedQuestions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "missedQuestionsCell", for: indexPath)

        cell.textLabel!.text = self.missedQuestions[indexPath.row].question

        for answer in self.missedQuestions[indexPath.row].answers{
            if answer.isCorrect{
                cell.detailTextLabel!.text = answer.answer
            }
        }

        return cell
    }

}
