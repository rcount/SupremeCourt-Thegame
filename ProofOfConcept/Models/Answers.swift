//
// Created by Stephen Vickers on 2/6/17.
// Copyright (c) 2017 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

class Answers {

    //MARK: - Private variable for the class

    //private variable to hold the answer for the instance of the class
    private var _answer = ""

    //private variable hold the question_Id for the instance of the class
    private var _questionID = 0

    //private variable to hold if the current instance is the correct answer for the question
    private var correct = false



    //MARK:  - Public Calculated Variable for the class

    //public calculated variable to get the access the answer for the class
    public var answer : String {
        //return    A String containing the answer for the class
        get{
            return self.getAnswer()
        }
        //param newValue    A String containing a new answer for the instance of this class
        set (newValue){
            self.setAnswer(answer: newValue)
        }
    }

    //public calculated variable to access the Question ID for the instance of this class
    public var questionID : Int {
        //return An Int holding the QuestionID for the class
        get{
            return self.getQuestionID()
        }
        //param newValue    An Int for to set the new questionID
        set(newValue){
            self.setQuestionID(questionID: newValue)
        }
    }

    //public calculated variable to access whether or not the current answer is the correct
    //one for the question
    public var isCorrect : Bool {
        //return    A Bool of whether the the current Answer is the correct one
        get{
            return self.getCorrect()
        }
        //param newValue    A Bool to set whether the current answer is correct or not
        set(newValue){
            self.setCorrect(correct: newValue)
        }

    }

    //MARK: - Constructors for the class

    //public default constructor for the class
    public init(){}

    //public overloaded constructor for the class
    //param answer      A String for the actual answer for the instance of this class
    //      questionId  An Int for the questionID for the question that this answer belongs to
    //      correct     A Bool to set whether the current Answers instance if the correct Answer for
    //                  the specified Question
    public init(answer: String, questionID : Int = 0, correct : Bool = false){
        self.setAnswer(answer: answer)
        self.isCorrect = correct
        self.questionID = questionID
    }

    //MARK: - Public Functions for the class

    //public function to set the Answer for the current instance of this class
    //param answer      A String containing the answer for the instance of this class
    public func setAnswer(answer: String){
        self._answer = answer
    }

    //public function to get the answer for the current instance of this class
    //return    A String holding the answer for the instance
    public func getAnswer() -> String {
        return self._answer
    }

    //public function to set the questionID of the class
    //each question has it's own unique ID, but can have multiple Answers associated with it
    public func setQuestionID(questionID : Int){
        self._questionID = questionID
    }

    //public function to get the Question ID for the instance of this class
    //return    An Int containing the Question ID to add the answer to that question
    public func getQuestionID() -> Int {
        return self._questionID
    }

    //public function to set if the current Answers instance is the correct choice
    //param correct     A Bool to set whether the instance is the correct choice for the answer or not
    public func setCorrect(correct: Bool) {
        self.correct = correct
    }

    //public function to get whether the current instance of the Answers class is the correct one
    //for the Question class
    //return    A Bool that for the correct status
    public func getCorrect() -> Bool {
        return self.correct
    }
}

//MARK: - Extensions for the class

//extension on Answers to make it conform to the Equatable protocol
extension Answers : Equatable {
    //pubic static func to see if an two Answers are equal
    //return    True if they are equal and false if they aren't
    public static func == (lhs: Answers, rhs: Answers) -> Bool{

        //if lhs and rhs refer to the same instance of the class then return true
        if lhs === rhs{
            return true
        }
        //else return the comparision of the answer for the lhs and rhs
        else {
            return lhs.answer.lowercased() == rhs.answer.lowercased()
        }
    }

    //public static function to compare an instance of Answers and An instance of Question
    //param lhs     An instance of the Answers Class
    //      rhs     An instance of the Question Class
    //return    True if the question Id from the Answer and Question match, false otherwise
    public static func == (lhs : Answers, rhs : Question) -> Bool {
        return lhs.questionID == rhs.questionID
    }

    //public static function to compare an instance of Answers and An instance of Question
    //param lhs     An instance of the Question Class
    //      rhs     An instance of the Answer Class
    //return    True if the question Id from the Answer and Question match, false otherwise
    public static func == (lhs : Question, rhs : Answers) -> Bool {
        return lhs.questionID == rhs.questionID
    }
    
}

//extension on Answer to make it conform to the CustomStringConvertible protocol
extension Answers: CustomStringConvertible{
    //public calculated variable to get the "description" of the Answer class
    //return    A String containing the Answer for the instance of this class
    public var description: String {
        return self.answer
    }
}

//extension on Answers to make it conform to the Hashable protocol
extension Answers: Hashable {
    //public calculate variable to get the hashValue for the instance of this class
    //return    An Int for the hash representation of the current instance of this class
    public var hashValue: Int {
        var hash = 31
        hash = hash ^ self.answer.hashValue
        hash = hash ^ (self.questionID * 100)
        hash = hash ^ self.isCorrect.hashValue
        return hash
    }
}
