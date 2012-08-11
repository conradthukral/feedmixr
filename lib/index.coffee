feedcombiner = require './feedcombiner'
RSS = require 'rss'
http = require 'http'

String::startsWith = (prefix) ->
	@substring(0, prefix.length) == prefix

feeds =
	'/op_egla':
		urls:
			[
				'http://www.op-online.de/lokales/nachrichten/langen/rssfeed.rdf',
				'http://www.op-online.de/lokales/nachrichten/egelsbach/rssfeed.rdf'
			]
		title: "Offenbach-Post Langen/Egelsbach"
		filter: (article) -> true
	'/op_dafrof':
		urls:
			[
				'http://www.op-online.de/lokales/nachrichten/rssfeed.rdf'
			]
		title: "Offenbach-Post Darmstadt/Frankfurt/Offenbach"
		filter: (article) ->
			text = article.description
			text.startsWith("Darmstadt") or text.startsWith("Frankfurt") or text.startsWith("Offenbach")


server = http.createServer (request, response) ->
	url = require('url').parse request.url
	feedInfo = feeds[url.pathname]

	console.log "Request from #{request.socket.remoteAddress} for #{url.pathname}"
	
	if feedInfo
		generateFeedFor feedInfo, (feed) ->
			response.setHeader "Content-Type", "application/rss+xml"
			response.end feed.xml()
	else
		response.statusCode = 404
		response.end()

generateFeedFor = (feedInfo, callback) ->
	feedcombiner.getCombinedArticles feedInfo.urls, feedInfo.filter, (articles) ->
		feed = new RSS
			title: feedInfo.title
			site_url: 'http://www.op-online.de'

		for article in articles
			feed.item
				url: article.link
				guid: article.guid
				date: article.date
				title: article.title
				description: article.description
				author: article.author
				categories: article.categories
		
		callback feed
	
port = process.env.PORT || 8080
server.listen port, ->
	console.log "Listening on #{port}"

