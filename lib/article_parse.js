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

	// Add a hook to make all links open a new window
	DOMPurify.addHook('afterSanitizeAttributes', function (node) {
		// set all elements owning target to target=_blank
		if ('target' in node) {
			node.setAttribute('target', '_blank');
		}
		// set non-HTML/MathML links to xlink:show=new
		if (
			!node.hasAttribute('target') &&
			(node.hasAttribute('xlink:href') || node.hasAttribute('href'))
		) {
			node.setAttribute('xlink:show', 'new');
		}
	});

	const clean = DOMPurify.sanitize(body);
	// console.log(body);
	// console.log('-------');
	// console.log('-------');
	// console.log('-------');
	// console.log('-------');
	// console.log(clean);

	const doc = new JSDOM(clean, {
		url: articleUrl,
	});

	medium_parse(doc);
	blogspot_parse(doc);

	let reader = new Readability(doc.window.document);
	let article = reader.parse();

	if (article['title'] === null || article['title'] === '') {
		article['title'] = body
			.match(/<title(.*?)>(.*?)<\/title>/)[2]
			.split('|')[0];
	}

	console.log(JSON.stringify(article));
});

function medium_parse(doc) {
	doc.window.document.querySelectorAll('picture').forEach((picture) => {
		picture.querySelectorAll('img').forEach((img) => {
			const imgSrc = picture
				.querySelector('source')
				.getAttribute('srcset')
				.split(' ')
				.filter((x) => x.startsWith('http'))
				.at(-1);

			img.setAttribute('src', imgSrc);
			img.removeAttribute('width');
			img.removeAttribute('height');
			img.removeAttribute('loading');
			picture.parentNode.insertBefore(img, picture);
		});
		picture.parentNode.removeChild(picture);
	});
}

function blogspot_parse(doc) {
	doc.window.document
		.querySelectorAll('.tr-caption-container')
		.forEach((caption) => {
			caption.querySelectorAll('img').forEach((img) => {
				img.removeAttribute('width');
				img.removeAttribute('height');
				caption.parentNode.insertBefore(img, caption);
			});
			caption.parentNode.removeChild(caption);
		});
}
