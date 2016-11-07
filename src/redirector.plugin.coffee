_ = require('lodash')

# Export Plugin
module.exports = (BasePlugin) ->
	# Define Plugin
	class RedirectorPlugin extends BasePlugin
		# Name
		name: 'redirector'

		# Config
		config:
			getRedirectTemplate: (destination) ->
				"""
				<!DOCTYPE html>
				<html>
					<head>
						<title>Redirect</title>
						<meta http-equiv="REFRESH" content="0;url=#{destination}">
					</head>
					<body>
						This page has moved. You will be automatically redirected to its new location. If you aren't forwarded to the new page, <a href="#{destination}">click here</a>.
					</body>
				</html>
				"""
			status: 301
			redirects: {}
		

		# Clean URLs for Document
		cleanSourceUrl: (source) =>
			if (source.substr(0,1) != "/") 
				source = '/' + source;
			source

		checkUrls: (source, destination) ->
			if (typeof source != "string" || typeof destination != "string") 
				throw """
					Error in redirector plugin configuration: all sources and destinations must be strings.
					Source: #{source}
					Destination: #{destination}
				"""

		# Runs at server startup (for dev / non-static environments)
		serverExtend: (opts, next) ->
			config = @config
			server = opts.server
			self = @
			docpad = @docpad
			
			_ = require('lodash')

			# for each redirect source we have, add a new express.get() route that redirects the visitor to the destination
			_.each config.redirects, (destination, source) ->
				self.checkUrls(source, destination)
				source = self.cleanSourceUrl source
				docpad.log 'debug', "Redirector setting up #{source} -> #{destination}"
				server.get source, (req, res) ->
					res.redirect config.status, destination

			# All done
			next()

		# After files are written (only for static environments)
		writeAfter: (opts,next) ->
			# Prepare
			self = @
			config = @config
			docpad = @docpad
			docpadConfig = docpad.getConfig()
			{TaskGroup} = require('taskgroup')
			safefs = require('safefs')
			pathUtil = require('path')
			getCleanOutPathFromUrl = (url) ->
				url = url.replace(/\/+$/,'')
				# if the path ends in .htm or .html or .shtml or .shtm, keep it as-is
				if /\.s?html?$/.test(url)
					pathUtil.join(docpadConfig.outPath, url)
				else
					# otherwise, create a directory at that path and give it an index.html
					pathUtil.join(docpadConfig.outPath, url.replace(/\.html$/,'')+'/index.html')

			# Static
			if 'static' in docpad.getEnvironments()
			
				# Tasks
				docpad.log 'debug', 'Writing static clean url files'
				tasks = new TaskGroup().setConfig(concurrency:0).once 'complete', (err) ->
					docpad.log 'debug', 'Wrote static clean url files'
					return next(err)

				# Create a .html file with a meta refresh for each redirect in the list
				_.each config.redirects, (destination, source) ->

					# Prepare
					self.checkUrls(source, destination)
					source = self.cleanSourceUrl source
					redirectOutPath = getCleanOutPathFromUrl(source)
					redirectContent = config.getRedirectTemplate(destination)

					tasks.addTask (complete) ->
						docpad.log 'debug', "Redirector setting up #{redirectOutPath} -> #{destination}"
						return safefs.writeFile(redirectOutPath, redirectContent, complete)

				# Fire
				tasks.run()

			# Development
			else
				next()

			# Chain
			@

