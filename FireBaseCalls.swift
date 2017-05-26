//
// Created by Stephen Vickers on 2/6/17.
// Copyright (c) 2017 ___FULLUSERNAME___. All rights reserved.
//

import Foundation

enum FireBaseCalls : String {

    //MARK: - Calls for the "Answers" -
    case answers = "/answers"
    case answer = "/answer"
    case correct = "/correct"

    //MARK: - Calls for the "Question Sets" -

    case questionsSets = "/question_sets"
    case questionSetName = "/question_set"
    case questionGroup = "/question_group"
    case questionGroupSetID = "/id_"

    //MARK: - Calls for the "Questions" -

    case questions  = "/questions"
    case questionID = "/question_id"
    case questionSetID = "/question_set_id"
    case question = "/question"

    //MARK: - Calls for the "Users" -
    case users = "/users"
    case userName = "/user_name"
    case userEmail = "/user_email"

}
