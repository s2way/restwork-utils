###
# Copyright(c) 2015 Juliano Jorge Lazzarotto aka dOob
# Apache2 Licensed
###

# Dependencies
expect = require 'expect.js'
Validator = require './../src/Validator'
Exceptions = require './../src/Exceptions'

describe 'Validator', ->

    describe 'validate', ->
        street = '7th East'
        city = 'New York'
        countryCode = 'US'
        email = 'test@waferpie.com'
        zipCode = '046800'
        preferences = [
            'Coffee'
            'Wafer'
            'Pie'
        ]
        socialNumber = '02895328099'
        password = '1fcae16a93d419692f469d8ac23faf844a5c3063'
        facebookId = '100434850640100011'
        data =
            socialNumber: socialNumber
            credentials:
                local:
                    email: email
                    password: password
                facebook:
                    id: facebookId
            address:
                street: street
                city: city
                countryCode: countryCode
                zipCode: zipCode
            preferences: preferences

        it 'should execute the validation functions passing each field to be validated', (done) ->
            validate =
                socialNumber: (value, data, cb) ->
                    expect(socialNumber).to.be value
                    cb()

                'credentials.local.email': (value, validationData, cb) ->
                    cb()

            validator = new Validator(
                validate: validate
                timeout: 1000
            )
            validator.validate data, (error, validatedFields, fieldErrors) ->
                expect(error).not.to.be.ok()
                expect(fieldErrors).to.eql {}
                done()

        it 'should execute the validation rules passing each field to be validated', (done) ->
            validate =
                email:
                    notEmpty: rule: 'notEmpty', message: 'This field cannot be empty'
                    email : rule: 'isEmail', message: 'This is not a valid e-mail address'
                'address.street':
                    'maxLength': rule: 'maxLength', message: 'Cannot contain more than 100 chars', params: [100]

            validator = new Validator(
                validate: validate
                timeout: 100
            )
            validator.validate data, (error, validatedFields) ->
                expectedValidatedFields =
                    email: true
                    'address.street': true

                expect(error).not.to.be.ok()
                expect(validatedFields).to.eql expectedValidatedFields
                done()


        it 'should return expired as true if the validation functions took too long', (done) ->
            validate =
                socialNumber: (value, validationData, callback) ->
                    setTimeout (->
                        callback()
                    ), 10000

                email: (value, validationData, callback) ->
                    callback()

            validator = new Validator(
                validate: validate
                timeout: 10
            )
            validator.validate data, (error) ->
                expect(error.name).to.be 'ValidationExpired'
                done()

    describe 'match', ->
        it 'should throw an error if the data is invalid', ->
            validate =
                title: false
                description: false

            validator = new Validator(validate: validate)
            expect(->
                validator.match title: -> return
            ).to.throwException((e) ->
                expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            )

        it 'should throw an error if the data is undefined or null', ->
            validator = new Validator(
                validate: {}
                field: true
            )
            expect(->
                validator.match()
            ).to.throwException((e) ->
                expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            )

        it 'should throw an error if the data is other thing besides a json', ->
            validator = new Validator(
                validate: {}
                field: true
            )
            expect(->
                validator.match -> return
            ).to.throwException((e) ->
                expect(e.name).to.be Exceptions.INVALID_ARGUMENT
            )

        it 'should return true if the data is according to the validate', ->
            validate =
                string: true
                array: true
                object:
                    object: array: false
                    number: true

            data =
                string: 'string'
                array: [0, 1, 3]
                object:
                    object: array: [0, 1, 2]
                    number: 100

            validator = new Validator(
                validate: validate
            )
            expect(validator.match data).to.be.ok()

        it 'should return an error if there is a field that is not specified in the validate', ->
            validate =
                string: false
                array: false
                object:
                    object: false
                    number: false

            data =
                object:
                    iShouldnt: 'beHere'

            validator = new Validator(
                validate: validate
            )
            result = validator.match data
            expect(result).to.eql
                field: 'object.iShouldnt'
                level: 2
                error: 'denied'

        it 'should return true if the field that would not match has been ignored', ->
            validate =
                string: false
                array: false
                object:
                    sub:
                        object: false
                        number: false

            data =
                object:
                    sub:
                        iShouldnt: 'beHere'

            skipMatch = ['object.sub']

            validator = new Validator(
                validate: validate,
                skipMatch: skipMatch
            )
            result = validator.match data
            expect(result).to.be true