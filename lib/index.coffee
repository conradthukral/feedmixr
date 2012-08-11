feedcombiner = require './feedcombiner'

RSS = require 'rss'
http = require 'http'
express = require 'express'

String::startsWith = (prefix) ->
	@substring(0, prefix.length) == prefix

feeds = [
	{
		url: '/op_egla'
		sourcUrls:
			[
				'http://www.op-online.de/lokales/nachrichten/langen/rssfeed.rdf',
				'http://www.op-online.de/lokales/nachrichten/egelsbach/rssfeed.rdf'
			]
		title: "Offenbach-Post Langen/Egelsbach"
		filter: (article) -> true
	},
	{
		url: '/op_dafrof'
		sourceUrls:
			[
				'http://www.op-online.de/lokales/nachrichten/rssfeed.rdf'
			]
		title: "Offenbach-Post Darmstadt/Frankfurt/Offenbach"
		filter: (article) ->
			text = article.description
			text.startsWith("Darmstadt") or text.startsWith("Frankfurt") or text.startsWith("Offenbach")
	}
]

app = express()
app.set 'view engine', 'jade'

for feedInfo in feeds
	console.log "Registering feed #{feedInfo.url}"
	app.get feedInfo.url, (request, response) ->
		console.log "Request from #{request.socket.remoteAddress} for #{feedInfo.url}"
	
		generateFeedFor feedInfo, (feed) ->
			response.setHeader "Content-Type", "application/rss+xml"
			response.end feed.xml()

app.get "/", (request, response) ->
	response.render 'index', { feeds: feeds }

generateFeedFor = (feedInfo, callback) ->
	feedcombiner.getCombinedArticles feedInfo.sourceUrls, feedInfo.filter, (articles) ->
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
app.listen port, ->
	console.log "Listening on #{port}"

