xml2js = require 'xml2js'

class XML
    constructor: (options = {}) ->
        @options =
            attrkey: options.attrkey || '@'
            charkey: options.charkey || '#'

    # Convert a JSON object to a XML string
    # @param {object} json The JSON object
    # @returns {string} The XML String
    fromJSON: (json) ->
        builder = new xml2js.Builder @options
        xml = builder.buildObject json
        xml

    # Convert a XML string to a JSON object
    # @param {string} xml The XML string to be converted
    # @returns {json} The JSON converted
    toJSON: (xml) ->
        json = null
        # This is NOT async!
        parser = new xml2js.Parser @options
        parser.parseString xml, (err, result) ->
            json = result
            throw err if err
            return
        json

    # Hides all info in the tag, replacing them with *
    # @param {string} tag The tag to hide
    # @param {string} originalXml The XML to iterate
    # @returns {string} XML with the hidden information
    hideInfoFromTag: (tag, originalXml) ->
        xml = originalXml.slice()
        index1 = (xml.search "<#{tag}>") + tag.length + 2
        index2 = xml.search "</#{tag}>"
        whatToHide = xml.substring index1, index2
        hidden = whatToHide.replace /./g, "*"
        xml = xml.replace whatToHide, hidden
        return xml

module.exports = XML