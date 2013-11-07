# Get Repos

[![NPM version](https://badge.fury.io/js/getrepos.png)](https://npmjs.org/package/getrepos)
[![Flattr this project](https://raw.github.com/balupton/flattr-buttons/master/badge-89x18.gif)](http://flattr.com/thing/344188/balupton-on-Flattr)

Fetch the specified repositories, or those that match a particular github user or search query


## Install

```
npm install --save getrepos
```


## Usage

``` javascript
// Create our getrepos instance
var getter = require('getrepos').create({
	githubClientId: null,      // optional, will try process.env.GITHUB_CLIENT_ID
	githubClientSecret: null,  // optional, will try process.env.GITHUB_CLIENT_SECRET
	log: console.log           // optional, arguments: level, message... 
});

// Fetch the data on these github repositories
getter.fetchRepos(['bevry/getrepos'], function(err){
	console.log(err);

	// Fetch all the repo data on these github users/organisations
	getter.fetchReposFromUsers(['bevry'], function(err){
		console.log(err);

		// Get the combined listing
		console.log(getter.getRepos());
	});
});
```

Repos are returned as an array of [repository objects](https://api.github.com/repos/bevry/getrepos).


## History
You can discover the history inside the `History.md` file


## License
Licensed under the incredibly [permissive](http://en.wikipedia.org/wiki/Permissive_free_software_licence) [MIT License](http://creativecommons.org/licenses/MIT/)
<br/>Copyright &copy; 2013+ [Bevry Pty Ltd](http://bevry.me)
