//
//  LaunchViewController.swift
//  ProofOfConcept
//
//  Created by Stephen Vickers on 2/14/17.
//  Copyright © 2017 Stephen Vickers. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseRemoteConfig

class LaunchViewController: UIViewController {

    //MARK: - instances of Objects used in this class -


    ///Array of Questions from the Question.Swift file for the class
    var tempQuestions = [Question]()

    var questions = [Question]()

    var groupNumbers = [Int]()

    //Array of Answers from the Answers.Swift file for the class
    var answers = [Answers]()

    private let TAG = "LaunchView"

    private var debug : Bool{
        #if DEGUG
                return true
        #else
                return false
        #endif
    }

    //DispatchGroup instance used to make asynchronous calls to Google Firebase Database to read the Questions and Answers
    let fireBaseGroup = DispatchGroup()

    let launchingArray = ["Launching.", "Launching..", "Launching..."]

    ///Reference to the Firebase Database.
    var fireBaseRef : FIRDatabaseReference!

    //Reference to the Firebase RemoteConfig
    var fireBaseRemote : FIRRemoteConfig!

    //MARK:  - IBOutlets for the view attached to the class -

    //Outlet for the label on the bottom of the screen
    @IBOutlet weak var launchLabelOutlet: UILabel!
   
    @IBOutlet weak var launchImageOutlet: UIImageView!
    //MARK: - Override of the UIViewController functions for this class -

    //override of the viewDidLoad function
    override func viewDidLoad() {
        super.viewDidLoad()


        //set the launchLabelOutlet text to something from the launch screen array
        self.launchLabelOutlet.text = self.launchingArray[2]
        
        self.launchImageOutlet.center = self.view.center
        self.launchImageOutlet.center = self.view.center
        self.launchLabelOutlet.center.y = self.launchImageOutlet.center.y + (self.launchImageOutlet.frame.height / 2) + 75


        //set the self.fireBaseRef instance to a reference to the Firebase Database
        self.fireBaseRef = FIRDatabase.database().reference()

        //set the self.fireBaseRemote member variable
        self.fireBaseRemote = FIRRemoteConfig.remoteConfig()

        //create an object to the Firebase Remote Config Settings Class
        let fireBaseRemoteSettings = FIRRemoteConfigSettings(developerModeEnabled: self.debug)
        self.fireBaseRemote.configSettings = fireBaseRemoteSettings!

        self.fireBaseRemote.setDefaultsFromPlistFileName("RCDefaults")

        //set up an array of functions to make the firebase requests to
        let request = [fetchGroupNumber, readGroupNumber, readQuestions, readAnswers]

        //iterate over the request and call each function as we go
        for index in 0..<request.count{
            //enter the firebaseGroup for each request
            fireBaseGroup.enter()

            //set function equal to request at the current index nad then call that function
            let function = request[index]
            function()
        }

        //Call the notify function on the self.firebaseGroup to get the notifications of when those calls are done
        //params    queue - an instance of DispatchQueue.main that is flagging that the asynchronous calls are done
        //          execute - a closure of what we want executed when the async calls are finished
        //                    we add the answers to the appropriate questions and then call self.showNextView()
        self.fireBaseGroup.notify(queue: DispatchQueue.main, execute: {


            for question in self.tempQuestions{
                if self.groupNumbers.contains(question.questionSet){
                    self.questions.append(question)
                }
            }

            for answer in self.answers{
                for question in self.questions{
                    if question == answer{
                        question.addAnswer(answer: answer)
                    }
                }
            }


            self.showNextView()
        })
    }

    //MARK: - Private Function for this class -

    //private function to show the next view, in this case the main questionView
    private func showNextView(){
        let mainVC = storyboard?.instantiateViewController(withIdentifier: "questionView") as! QuestionViewController
        mainVC.questions = self.questions
        self.present(mainVC, animated: true)
    }

    private func fetchGroupNumber(){

        let cacheExpireTime = self.debug ? 0 : 3600

//        if self.fireBaseRemote.configSettings.isDeveloperModeEnabled {
//            cacheExpireTime = 0
//        }

        self.fireBaseRemote.fetch(withExpirationDuration: TimeInterval(cacheExpireTime)) { (status, error) -> Void in

            if status == FIRRemoteConfigFetchStatus.success {
                self.fireBaseRemote.activateFetched()
            }

            else{
                print("Error: \(error!.localizedDescription)")
            }
        }

        self.fireBaseGroup.leave()
    }

    private func readGroupNumber(){


        let groupRef = self.fireBaseRef.child(FireBaseCalls.questionGroup.rawValue)

        groupRef.observe(.value, with: {
            (snapshot: FIRDataSnapshot!) in

            let size = Int(snapshot.childrenCount)


            for index in 0..<size{


                let group = Int(self.fireBaseRemote["question_group"].stringValue!)


                if let questionGroup = snapshot.childSnapshot(forPath: "\(index)").value{
                    if index == group{
                        let questionSets = snapshot.childSnapshot(forPath: "\(index)\(FireBaseCalls.questionsSets.rawValue)")

                        let setSize = Int(questionSets.childrenCount)

                        for index2 in 0..<setSize{
                            let setNumber = questionSets.childSnapshot(forPath: "\(FireBaseCalls.questionGroupSetID.rawValue)\(index2)").value as! Int


                            self.groupNumbers.append(setNumber)
                        }

                    }
                }

            }
        })

        self.fireBaseGroup.leave()
    }


    ///private function to read the the questions and answers from Firebase
    private func readQuestions(){

        //reference to the Questions part of the firebase
        let questionRef = self.fireBaseRef.child(FireBaseCalls.questions.rawValue)
        
        //observe the Questions, This fires on first start up and then again anytime there is a change to the data on the server
        questionRef.observe(.value, with : {
            snapshot in


            //get the number of children on the snapshot and set that to the size
            let size = Int(snapshot.childrenCount)

            //iterate over the questions based on the indexes
            //we use the indexes because they are returned as an AnyClass object and that doesn't conform to sequence protocol
            for index in 0..<size {

                //make sure there is valid question
                if let question = snapshot.childSnapshot(forPath: "\(index)\(FireBaseCalls.question.rawValue)").value{

                    //make sure there is a valid questionID
                    if let questionID = snapshot.childSnapshot(forPath: "\(index)\(FireBaseCalls.questionID.rawValue)").value  {

                        //make sure there is a valid questionSetID
                        if let questionSetID = snapshot.childSnapshot(forPath: "\(index)\(FireBaseCalls.questionSetID.rawValue)").value {

                            //create a temp question and add it to the question array
                            let temp = Question(question: question as! String, questionSet: Int(String(describing: questionSetID))!, questionID: Int(String(describing: questionID))!)
                            self.tempQuestions.append(temp)

                        }
                    }
                    
                }
                
                
            }


            //tell firebaseGroup to leave this function and stop this async call
            self.fireBaseGroup.leave()
        })
    }

    //private Function to read the answers for the questions from the Firebase Database
    private func readAnswers()  {



        //get a reference to the "answers" node of the database
        let answerRef = self.fireBaseRef.child("answers")

        //Call the observe method for that node
        answerRef.observe(.value, with: {
            snapshot in

            //get the number of children for that node, which is the number of questions we have
            //cast to an Int because it returns an UInt
            let size = Int(snapshot.childrenCount)

            //iterate over the number of of children in the answerRef
            for index in 0..<size {

                //make sure we have a valid answer
                if let answer = snapshot.childSnapshot(forPath: "/\(index)/answer").value {

                    //make sure we have a valid true or false for if the answer is the correct answer or not
                    if let correct = snapshot.childSnapshot(forPath: "/\(index)/correct").value{

                        //make sure we have a valid questionID for the current answer
                        if let questionID = snapshot.childSnapshot(forPath: "/\(index)/question_id").value{

                            //set a tempAnswer and cast it as String
                            let tempAnswer = answer as! String

                            //set a tempCorrect and cast it as Bool
                            let tempCorrect = correct as! Bool

                            //set a tempId and cast it as an Int
                            let tempId = questionID as! Int

                            //create a temp Answers and pass the appropriate data
                            let temp = Answers(answer: tempAnswer, questionID:  tempId, correct: tempCorrect)

                            //add the temp Answer to the answer array
                            self.answers.append(temp)
                        }

                    }
                }

            }

            
            //leave the firebaseGroup and tell it that this async call is cone
            self.fireBaseGroup.leave()
        })
    }

}
