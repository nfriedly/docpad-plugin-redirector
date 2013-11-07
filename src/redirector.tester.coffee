# Export Plugin Tester
module.exports = (testers) ->
	# PRepare
	{expect} = require('chai')
	request = require('request')

	# Define My Tester
	class MyTester extends testers.ServerTester
		# Test Generate
		testGenerate: testers.RendererTester::testGenerate

		# Custom test for the server
		testServer: (next) ->
			# Prepare
			tester = @

			# Create the server
			super

			# Test
			@suite 'redirector', (suite,test) ->
					
				# setup another website to redirect to
				http = require('http')
				sitebPort = 12345
				siteb = http.createServer (req, res) ->
					res.writeHead(200, {'Content-Type': 'text/plain'});
					res.end(req.url);
				siteb.listen(sitebPort);
				sitebUrl = "http://localhost:#{sitebPort}"

				# Prepare
				baseUrl = "http://localhost:#{tester.docpad.config.port}"
				outExpectedPath = tester.config.outExpectedPath
				isStatic = tester.docpad.config.env == 'static'

				#if isStatic
				#else
				
				test 'test setup: siteb server should respond with path', (done) ->
					fileUrl = "#{sitebUrl}/test-path"
					expectedStr = '/test-path'
					request fileUrl, (err,response,actual) ->
						return done(err)  if err
						actualStr = actual.toString()
						expect(actualStr).to.equal(expectedStr)
						done()
					
				test 'server should serve URLs ending in .html', (done) ->
					fileUrl = "#{baseUrl}/offsite.html"
					expectedStr = '/html-result'
					request fileUrl, (err,response,actual) ->
						return done(err)  if err
						actualStr = actual.toString()
						expect(actualStr).to.equal(expectedStr)
						done()

				test 'server should serve URLs without extensions', (done) ->
					fileUrl = "#{baseUrl}/offsite-directory"
					expectedStr = '/directory-result'
					request fileUrl, (err,response,actual) ->
						return done(err)  if err
						actualStr = actual.toString()
						expect(actualStr).to.equal(expectedStr)
						done()
						
				# wrap up (todo: check if there is an afterClass sort of method this belongs in?)
				test 'wrapping up', (done) ->
					siteb.close(done)
