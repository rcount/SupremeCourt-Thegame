//
//  ViewController.swift
//  ProofOfConcept
//
//  Created by Stephen Vickers on 2/2/17.
//  Copyright (c) 2017 Stephen Vickers. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth


class QuestionViewController: UIViewController {

    //MARK: - Internal Variables for the QuestionViewController -

    ///Internal Array of Questions from the Question.Swift file for the class
    ///Declared Internal  because we need to access it inside the launch view controller.
    internal var questions = [Question]()

    internal var missedQuestions = [Question]()

    ///MARK: - FilePrivate Variables for the QuestionViewController File -


    ///FilePrivate Variable to hold the current question Number that we are on
    fileprivate var questionNumber = 0

    ///FilePrivate Variable to hold the number of correct answers the student has selected
    fileprivate var numberOfCorrectQuestions = 0

    ///Variable to hold the correct answer for the current question
    fileprivate var correctAnswer = ""

    ///Variable to hold the correctChoice for the current question
    fileprivate var correctChoice = ""

    private let firebaseAuth = FIRAuth.auth()


    //MARK: - Private variables for used in the view -

    ///private constant for logging
    fileprivate let TAG = "MainView"
    
    ///private string Constant for logging
    private let checkButton = "checkButton"

    ///private string Constant for logging
    private let nextButton = "nextButton"

    ///Private variable to hold the number of correct choices for the student
    private var correctNumber = 0

    ///Reference to the Firebase Database.
    private var fireBaseRef : FIRDatabaseReference!

    //MARK: - Outlets from the Main.storyboard file -

    ///Outlet for the for the question label
    @IBOutlet weak var questionLabelOutlet: UILabel!

    ///Outlet for the next button
    @IBOutlet weak var nextButtonOutlet: UIDesignableButton!

    ///Outlet for the checkButton
    @IBOutlet weak var checkButtonOutlet: UIDesignableButton!

    ///Outlet for the TableView to hold the answers
    @IBOutlet weak var answerTableViewOutlet: UITableView!
    
    ///Outlet for the LogoutButton
    @IBOutlet weak var logoutButtonOutlet: UIButton!
    
    @IBOutlet weak var questionCardOutlet: UIDesignableView!
    

    //MARK: - Override of the UIViewController functions we need for this view -
    
    ///override of the viewWillAppear function so we can set the questionNumber to 0 and load that question
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)

        //set the questionNumber to 0 and update load the question on the screen
        self.questionNumber = 0
        self.updateQuestion()

        self.correctNumber = 0
        self.correctChoice = ""
        self.correctAnswer = ""

    }

    ///override of the viewDidLoad function that we use to setup the elements of the view
    override func viewDidLoad() {
        super.viewDidLoad()

        //Set the dataSource and the delegate for the answerTableViewOutlet
        self.answerTableViewOutlet.dataSource = self
        self.answerTableViewOutlet.delegate = self


        //set the next button to center to the center of the check button and hide it
        self.nextButtonOutlet.center = self.checkButtonOutlet.center
        self.hideButton(self.nextButtonOutlet, buttonName: self.nextButton)

        //set the row height for the answerTableView to Automatic Dimension
        //this way it will resize on it's own
        self.answerTableViewOutlet.rowHeight = UITableViewAutomaticDimension
        
        //set the estimatedRowHeight so the answersTableView has an initial size to allocate the cells
        self.answerTableViewOutlet.estimatedRowHeight = 50

        //add a tableFooterView to the answerTableView
        //this is so the answerTableView is truncated at the number of answers we have
        //and it wont show empty cells
        self.answerTableViewOutlet.tableFooterView = UIView(frame: .zero)
        
        self.logoutButtonOutlet.center.y = self.view.frame.height - 50
        self.logoutButtonOutlet.center.x = self.view.center.x
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.viewDidRoatate(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self)
    }

    //MARK: - Actions for the Items in the view -

    ///TouchUpInside action for the checkButton
    ///-parameter: 
    ///  -sender: sender for the connected UIDesignableButton
    @IBAction func checkButtonTouchUp(_ sender: UIDesignableButton) {


        //hide the checkButton and show the nextButton
        self.hideButton(self.checkButtonOutlet, buttonName: self.checkButton)
        self.showButton(self.nextButtonOutlet, buttonName: self.nextButton)
        
    }

    ///TouchUpInside action for the next Button
    ///param     sender for the connected UIDesignableButton
    @IBAction func nextButtonTouchUp(_ sender: UIDesignableButton) {

        //hide the nextButton and show the checkButton
        self.hideButton(self.nextButtonOutlet, buttonName: self.nextButton)
        self.showButton(self.checkButtonOutlet, buttonName: self.checkButton)


        if self.checkAnswer(){
            self.correctNumber += 1

        }else{
            self.missedQuestions.append(self.questions[self.questionNumber])
        }

        //update the question number
        self.updateQuestionNumber()

        //update the question on the screen
        self.updateQuestion()
    }

    @IBAction func logoutButtonTouchUP(_ sender: UIButton) {
        do {
            try firebaseAuth?.signOut()
            let registerScreen = storyboard?.instantiateViewController(withIdentifier: "registerScreen") as! RegisterViewController
            self.present(registerScreen, animated: true)

        }catch let  error   {
            print("\(self.TAG) Error Signing out \(error)")
        }
    }

    //MARK: - FilePrivate functions -

    ///FilePrivate Function to compare an answer choice to the correctAnswer
    fileprivate func checkAnswer() -> Bool{
        return self.correctAnswer == self.correctChoice
    }

    //MARK: - Private Functions for the view that are used -


    ///private Function to transition to the score screen
    private func showScoreScreen(){

        //set and instance of the scoreView Screen and pass it the score and total that is accumulated during the quiz
        let scoreView = storyboard?.instantiateViewController(withIdentifier: "scoreView") as! ScoreViewController
        scoreView.score = self.correctNumber
        scoreView.total = self.questions.count
        scoreView.missedQuestions = self.missedQuestions


        //show the score screen
        self.present(scoreView, animated: true)
    }


    ///private Function to up date the current question on the screen
    private func updateQuestion(){

        self.correctChoice = ""

        self.questionLabelOutlet.text = self.questions[self.questionNumber].question

        self.answerTableViewOutlet.reloadData()
    }


    ///Private function to up date the question number
    ///if the question number is at the lat question then we call sel.showScoreScreenFunction()
    private func updateQuestionNumber(){
        if self.questionNumber < self.questions.count - 1 {
            self.questionNumber += 1
        }
        else {
            self.showScoreScreen()
        }

    }


    /*
     private function to show a UIButton.
     this is used for the self.checkButtonOutlet and the self.nextButtonOutlet even though they are
     UIDesignableButton instead of UIButton Since they inherited from UIButton they can be passed here
     /**
     -parameters:
     --button: UIButton to be shown
     --buttonName: The name of the Button passed to the function so we can log it on the console during debug
     */
     */
    private func showButton(_ button: UIButton, buttonName: String){
        button.alpha = 1

    }

    ///private function to hide a UIButton.
    ///this is used for the self.checkButtonOutlet and the self.nextButtonOutlet even though they are
    ///UIDesignableButton instead of UIButton Since they inherited from UIButton they can be passed here
    ///param     button UIButton to be hidden
    private func hideButton(_ button: UIButton, buttonName: String){

        button.alpha = 0
    }
    
    @objc private func viewDidRoatate(_ notification: NSNotification){
        
        self.questionCardOutlet.center = self.view.center
        
        self.logoutButtonOutlet.center.y = self.view.frame.height - 50
        self.logoutButtonOutlet.center.x = self.view.center.x
    }
    


}


//MARK: - Extensions for the QuestionViewController -

extension QuestionViewController: UITableViewDataSource {

    //MARK: - Functions for the UITableView that is used for the answers -

    ///Function to set the number of rows in the UITableView
    ///     @param tableView     The table view of that this class works with
    ///     @param numberOfRowsInSection     Number of the rows in the current section
    ///     @return    the number of answers in the currentQuestion
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.questions[self.questionNumber].answerCount
    }

    ///Function to build a cell
    ///@param tableView     The table view of that this class works with
    ///@param cellForRowAt      The current cell at the the index provided
    ///return    the new cell with the current information inside of it
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //build a cell as a UIResizableTableViewCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "answerCell", for: indexPath)

        //set the text of the cell.answerLabel to one of the answers from the current question
        cell.textLabel!.text = self.questions[self.questionNumber].answers[indexPath.item].answer

        if self.questions[self.questionNumber].answers[indexPath.item].isCorrect{
            self.correctAnswer = self.questions[self.questionNumber].answers[indexPath.item].answer

        }

        cell.accessoryType = .none

        return cell
    }
}

extension QuestionViewController: UITableViewDelegate{

    //Mark: - functions to make QuestionViewController conform to UITableViewDelegate

    ///Function to tell if you selected a row
    ///@param tableView     The table view that this class works with
    ///@param indexPath     The index of the cell that was selected
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        if cell!.accessoryType == .checkmark{
            cell!.accessoryType = .none
            self.correctChoice = ""
        } else {
            cell!.accessoryType = .checkmark
            self.correctChoice = cell!.textLabel!.text!

        }

    }


    ///function for when a user selects a second, third, etc cell on the answerTableView
    ///@param tableView     The table view of that this class works with
    ///@param didDeselectRowAt      The indexPath for the cell that was deselected
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell!.accessoryType = .none
        self.correctChoice = ""

        print("didDeselectRowAt called")
    }
}



