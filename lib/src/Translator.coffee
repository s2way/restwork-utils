class Message

    constructor: (strings, lang, deps) ->
        TextChocolate = deps?.TextChocolate || require 'textchocolate'
        @tc = new TextChocolate strings, lang if strings

    get: (message, type, lang) ->
        @tc.lang lang if lang?
        return @tc.translate message, type if @tc
        message

module.exports = Message
