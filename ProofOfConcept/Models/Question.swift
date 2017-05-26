//
// Created by Stephen Vickers on 2/6/17.
// Copyright (c) 2017 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

class Question  {

    //MARK: - Private variable for the Question Class

    ///private array to hold a list of answers in
    private var answersList = [Answers]()

    ///private string to hold the question in
    private var _question = ""

    ///private Int to hold the Question Set in
    ///a Question Set is a group of questions related to the same topic
    private var _questionSet = 0

    ///private Int to hold the Question Id in
    ///Question Id's are unique to the question inside of Firebase
    private var _questionID = 0

    //MARK: - Public calculated variable for the Question class

    ///public calculated variable to access the question string for the class
    public var question : String {
        //return    A String containing the question for the class
        get {
            return self.getQuestion()
        }
        //param newValue    A String containing the question for the current instance of the class
        set (newValue){
            self.setQuestion(question: newValue)
        }
    }

    ///public calculated variable to get and set the questionID of the question
    public var questionID : Int {
        get{
            return self.getQuestionID()
        }
        set (newValue){
            self.setQuestionID(questionID: newValue)
        }
    }

    ///public calculated variable to get and set the questionSet of the question
    public var questionSet : Int {
        get{
            return self.getQuestionSet()
        }

        set(newValue){
            self.setQuestionSet(questionSet: newValue)
        }
    }

    ///public calculated variable to get access to the answersList for the current question
    public var answers: [Answers] {
        //return an array of answers
        get{
            return self.getAllAnswers()
        }
    }

    ///public calculated variable to get the number of answers for the question
    public var answerCount : Int {
        get {
            return self.answersList.count
        }
    }

    //MARK: - Constructors for the Question List

    ///public default constructor for the class
    public init(){}

    ///public overloaded constructor for the class
    ///-paramets:
    ///   -question: A string to pass in a question to the class
    ///   -questionSet: An Int holding the question set the the the question belongs to
    ///   -questionID: An Int for the individual questionId for the current question
    public init(question: String, questionSet : Int = 0, questionID : Int = 0) {
        self.setQuestion(question: question)
        self.setQuestionID(questionID: questionID)
        self.setQuestionSet(questionSet: questionSet)
    }

    //MARK: - Public functions for the Question Class

    ///public function to set the question for the instance of this class
    /// -parameter question: A String to pass in the question
    public func setQuestion(question : String){
        self._question = question
    }

    ///public function to get the question for the instance of this class
    ///  -returns: A string containing the question for the instance of this class
    public func getQuestion() -> String{
        return self._question
    }

    ///public function to set the number of the Question Set for this question
    ///  -parameter questionSet     An Int to pass in the questionSet for the instance of this class
    public func setQuestionSet(questionSet : Int) {
        self._questionSet = questionSet
    }

    ///public function to get the Question Set of this question
    ///  -return: An Int containing the questionSet number for the instance of this class
    public func getQuestionSet() -> Int {
        return self._questionSet
    }

    ///public function to set the Question ID for the instance of this class
    /// -parameter questionID: An Int that contains the Unique number for the Question ID for the instance of this class
    public func setQuestionID(questionID : Int){
        self._questionID = questionID
    }

    ///public function to get the Question Id for the instance of this class
    ///  -return: An Int that contains the unique number for the current instance of this class
    public func getQuestionID() -> Int {
        return self._questionID
    }

    ///public function to add an instance of the Answers class to the question
    ///  -parameter answer: An Answers instance to be added to the current
    public func addAnswer(answer : Answers){
        self.answersList.append(answer)
    }

    ///public function to get an Answer at a specific index
    ///  -return: An instance of the Answer class at an index in the self.answersList array
    public func getAnswer(index : Int) -> Answers{
        return self.answersList[index]
    }

    ///public function to get all the answers for the class
    /// -return: An Array of Answers for the class
    public func getAllAnswers() -> [Answers]{
        return self.answersList
    }

    //MARK: - Public SubScript for the Question Class

    ///public subscript on the Question Class to get an answer at the specified index
    /// -return:An answer at the specified index
    public subscript(_ index : Int) -> Answers{
        get{
            return  self.getAnswer(index: index)
        }
    }
}

//MARK: - Extensions for the Question Class

///Extension on Question to make it conform to CustomStringConvertible protocol
extension Question : CustomStringConvertible {

    ///public calculated variable to get the "description" of the Question
    ///  -return: A string containing the question of the class
    public var description: String {
        return  (self.getQuestion())
    }
}

///extension on Question to make it conform to Hashable protocol
extension Question : Hashable {

    ///public Calculated variable to get the hashValue for the current Question
    ///  -return: An Int of the current hashValue
    public var hashValue : Int {
        var hash = 31
        hash = hash ^ self.getQuestion().hashValue

        for answer in self.getAllAnswers(){
            hash = hash ^ answer.hashValue
        }

        return hash
    }
}

///Extension on Question to make it conform to the Equatable protocol
///this is needed for the Hashable Protocol
extension Question: Equatable {

    ///Public static function to compare two Questions
    /// - return: A Bool of whether or not the two questions in the class are the same
    public static func == (lhs: Question, rhs: Question) -> Bool{
        return lhs.getQuestion().lowercased() == rhs.getQuestion().lowercased()
    }
}
