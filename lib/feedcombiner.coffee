feedfetcher = require './feedfetcher'

sortArticles = (allArticles) ->
	allArticles.sort (article1, article2) ->
		if not article2.date
			return -1
		if not article1.date
			return 1
		article1.date - article2.date

exports.getCombinedArticles = (urls, filter, callback) ->
	allArticles = []
	doneCount = 0
	integrateArticlesFromOneStream = (error, meta, articles) ->
		if error
			console.log "ERROR: #{error}"
		else
			for article in articles
				allArticles.push article if filter(article)
		if ++doneCount == urls.length
			sortArticles allArticles
			callback allArticles
	
	for url in urls
		feedfetcher.fetch url, integrateArticlesFromOneStream

