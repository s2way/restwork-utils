###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

# Dependencies
_ = require 'underscore'
Exceptions = require './Exceptions'

class Validator

    # Defaults
    @DEFAULT_TIMEOUT: 10000

    # Params
    @PARAMS_TIMEOUT: 'timeout'
    @PARAMS_VALIDATE: 'validate'
    @PARAMS_SKIP_MATCH: 'skipMatch'

    # @param {object} params MUST contain the validation rules (validate property) and may contain the timeout(ms)
    constructor: (params = {}, container) ->
        # Injectable dependencies - tests only because it is lazy instantiate
        @Rules = container?.Rules || require './Rules'
        @Navigator =  container?.Navigator || require './Navigator'

        # Defaults
        @timeout = params[Validator.PARAMS_TIMEOUT] ? Validator.DEFAULT_TIMEOUT
        @skipMatch = params[Validator.PARAMS_SKIP_MATCH] ? []
        @validatorRules = params[Validator.PARAMS_VALIDATE]

    # Validate fields
    _succeeded: (fieldErrors) ->
        for expression of fieldErrors
            return false if fieldErrors[expression]?
        true

    # Find all fields to validate
    _hasValidatedAllFields: (validatedFields, validate) ->
        for expression of validate
            return false unless validatedFields[expression]?
        true

    # Validate all properties of a json
    # @method validate
    # @param {object} data The json object to be validated
    # @param {function} callback
    validate: (data, callback) ->
        validate = @validatorRules
        fieldErrors = {}
        validatedFields = {}
        expired = false
        succeeded = false

        for expression of validate
            fieldRule = validate[expression]

            value = @Navigator.get data, expression

            if typeof fieldRule is 'function'
                fieldRule(value, data,
                    ((expression) ->
                        return (error) ->
                            validatedFields[expression] = true
                            fieldErrors[expression] = error if error
                    )(expression)
                )
            else
                result = @_test value, fieldRule
                fieldErrors[expression] = result if result
                validatedFields[expression] = true

        # Start a timer to control validations
        timer = setTimeout(->
            expired = true
        , @timeout)

        timeoutFunc = =>
            if expired
                callback
                    name: 'ValidationExpired'
                , validatedFields, fieldErrors
            else if @_hasValidatedAllFields(validatedFields, validate)
                clearTimeout timer
                succeeded = @_succeeded(fieldErrors)
                unless succeeded
                    return callback
                        name: 'ValidationFailed'
                        fields: fieldErrors
                    , validatedFields, fieldErrors
                callback null, validatedFields, fieldErrors
            else
                setTimeout timeoutFunc, @timeout / 500

        timeoutFunc()

    _matchAgainst: (data, skipMatch = @skipMatch, level = 1, validate = @validatorRules, expression = '') ->

        # check schema field presence
        for key of data
            # if field must not be ignored
            if (expression + key) in skipMatch
                continue
            # schema for this field was not set, block
            if validate[expression + key] is undefined
                return (
                    field: expression + key
                    level: level
                    error: 'denied'
                )

            # validate set and it is an object: recursive
            if data[key] isnt null and typeof data[key] is 'object'
                test = @_matchAgainst(data[key], skipMatch, level + 1, validate[expression + key], expression + key + '.')
                return test if test isnt true
        true

    _isJSONValid: (jsonOb) ->
        return false unless jsonOb?
        try
            newJSON = JSON.parse(JSON.stringify(jsonOb))
        catch e
            return false
        return newJSON if Object.getOwnPropertyNames(newJSON).length > 0
        false


    # Match the data against the validate object specified in the constructor
    # If there are fields in the data that are not specified in the validate object, this method returns false
    # @param {object} data The data to be matched
    # @return {boolean}
    match: (data) ->
        newData = @_isJSONValid data
        throw new Exceptions.Error Exceptions.INVALID_ARGUMENT, 'Data' unless newData
        @_matchAgainst data

    # Test if a value will pass a set of validation rules specified in the rules parameter
    # @value The value to be validated
    # @rules {object} A JSON containing the rules to be tested against the fields
    # See the tests for examples
    _test: (value, rules) ->
        @Rules.test value, rules

module.exports = Validator
