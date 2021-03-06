# Test our plugin using DocPad's Testers

pluginConfig = 
	redirector:
		redirects:
			'offsite.html' : "http://localhost:12345/html-result"
			'offsite-directory' : "http://localhost:12345/directory-result"

require('docpad').require('testers')
	.test(
			testerName: 'redirector development environment'
			pluginPath: __dirname+'/..'
			testPath: __dirname+'/../test/development'
			autoExit: 'safe'
		,
			env: 'development'
			plugins: pluginConfig
	)
	.test(
			testerName: 'redirector static environment'
			pluginPath: __dirname+'/..',
			testPath: __dirname+'/../test/static'
		,
			env: 'static'
			plugins: pluginConfig
	)