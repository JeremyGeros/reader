const { Readability } = require('@mozilla/readability');
const { JSDOM } = require('jsdom');
const request = require('request');
const createDOMPurify = require('dompurify');

const articleUrl = process.argv[2];
const url = process.argv[3];

request({ uri: url }, function (error, response, body) {
	// console.log('error:', error); // Print the error if one occurred
	// console.log('statusCode:', response && response.statusCode); // Print the response status code if a response was received
	// console.log('body:', body); // Print the HTML for the Google homepage.
	// console.log(url);
	// console.log(articleUrl);

	const window = new JSDOM('').window;
	const DOMPurify = createDOMPurify(window);
	// const clean = DOMPurify.sanitize(body);

	const doc = new JSDOM(body, {
		url: articleUrl,
	});

	let reader = new Readability(doc.window.document);
	let article = reader.parse();
	console.log(JSON.stringify(article));
});
