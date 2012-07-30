feedcombiner = require './feedcombiner'
RSS = require 'rss'
http = require 'http'

urls = [
	'http://www.op-online.de/lokales/nachrichten/langen/rssfeed.rdf',
	'http://www.op-online.de/lokales/nachrichten/egelsbach/rssfeed.rdf'
]

server = http.createServer (request, response) ->
	feedcombiner.getCombinedArticles urls, (articles) ->
		feed = new RSS
			title: "Offenbach-Post Langen/Egelsbach"
			site_url: 'http://www.op-online.de'

		for article in articles
			feed.item
				url: article.url
				guid: article.guid
				date: article.date
				title: article.title
				description: article.description

		response.setHeader "Content-Type", "application/rss+xml"
		response.end feed.xml()

port = process.env.PORT || 8080
server.listen port, ->
	console.log "Listening on #{port}"

