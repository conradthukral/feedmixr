http = require 'http'
FeedParser = require 'feedparser'

exports.fetch = (url, callback) ->
	http.get url, (response) ->
    console.log "Got #{response.statusCode} for #{url}"
    parser = new FeedParser()
    parser.parseStream(response, callback)

