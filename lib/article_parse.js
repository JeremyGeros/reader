const { Readability } = require('@mozilla/readability');
const { JSDOM } = require('jsdom');
const request = require('request');
const createDOMPurify = require('dompurify');

const articleUrl = process.argv[2];
const url = process.argv[3];
const articleId = process.argv[4];

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

	if (node.nodeName === 'A') {
		node.setAttribute('rel', 'noopener noreferrer');

		if (node.hasAttribute('href')) {
			const href = node.getAttribute('href');
			const pureUrl = purifyUrl(href);
			if (pureUrl) {
				node.setAttribute('href', pureUrl);
			} else {
				node.removeAttribute('href');
			}
		}
	}
});

request({ uri: url }, function (error, response, body) {
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

	// if (article['title'] === null || article['title'] === '') {
	// 	article['title'] = body
	// 		.match(/<title(.*?)>(.*?)<\/title>/)[2]
	// 		.split('|')[0];
	// }

	const extras = extract_extras(body);
	extras['ttr'] = getTimeToRead(article['textContent']);

	// const content = new JSDOM(article['content'], {
	// 	url: articleUrl,
	// });

	// let linkIndex = 0;
	// content.window.document
	// 	.querySelectorAll('p, div, h1, h2, h3, h4, h5, h6, ul, ol')
	// 	.forEach((element) => {
	// 		if (
	// 			element.getAttribute('id') === '' ||
	// 			element.getAttribute('id') === null
	// 		) {
	// 			element.setAttribute('id', `article-${articleId}-link-${linkIndex}`);
	// 			linkIndex++;
	// 		} else {
	// 			element.setAttribute(
	// 				'id',
	// 				`article-${articleId}-${element.getAttribute('id')}`
	// 			);
	// 		}
	// 	});

	// article['content'] = content.serialize();

	console.log(JSON.stringify({ ...article, ...extras }));
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

function extract_extras(html) {
	const entry = {
		url: '',
		shortlink: '',
		amphtml: '',
		canonical: '',
		title: '',
		description: '',
		image: '',
		author: '',
		source: '',
		published: '',
		ttr: 0,
	};

	const sourceAttrs = [
		'application-name',
		'og:site_name',
		'twitter:site',
		'dc.title',
	];
	const urlAttrs = ['og:url', 'twitter:url'];
	const titleAttrs = ['title', 'og:title', 'twitter:title'];
	const descriptionAttrs = [
		'description',
		'og:description',
		'twitter:description',
	];
	const imageAttrs = [
		'image',
		'og:image',
		'og:image:url',
		'og:image:secure_url',
		'twitter:image',
		'twitter:image:src',
	];
	const authorAttrs = [
		'author',
		'creator',
		'og:creator',
		'article:author',
		'twitter:creator',
		'dc.creator',
	];
	const publishedTimeAttrs = [
		'article:published_time',
		'article:modified_time',
		'og:updated_time',
		'dc.date',
		'dc.date.issued',
		'dc.date.created',
		'dc:created',
		'dcterms.date',
		'datepublished',
		'datemodified',
		'updated_time',
		'modified_time',
		'published_time',
		'release_date',
		'date',
	];

	const DOMParser = window.DOMParser;
	const document = new DOMParser().parseFromString(html, 'text/html');
	entry.title = document.querySelector('head > title')?.innerHTML;

	Array.from(document.getElementsByTagName('link')).forEach((node) => {
		const rel = node.getAttribute('rel');
		const href = node.getAttribute('href');
		if (rel && href) entry[rel] = href;
	});

	Array.from(document.getElementsByTagName('meta')).forEach((node) => {
		const content = node.getAttribute('content');
		const property =
			node.getAttribute('property')?.toLowerCase() ??
			node.getAttribute('itemprop')?.toLowerCase();
		const name = node.getAttribute('name')?.toLowerCase();

		if (sourceAttrs.includes(property) || sourceAttrs.includes(name)) {
			entry.source = content;
		}
		if (urlAttrs.includes(property) || urlAttrs.includes(name)) {
			entry.url = content;
		}
		if (titleAttrs.includes(property) || titleAttrs.includes(name)) {
			if (!entry.title || entry.title === '') {
				entry.title = content;
			}
		}
		if (
			descriptionAttrs.includes(property) ||
			descriptionAttrs.includes(name)
		) {
			entry.description = content;
		}
		if (imageAttrs.includes(property) || imageAttrs.includes(name)) {
			entry.image = content;
		}
		if (authorAttrs.includes(property) || authorAttrs.includes(name)) {
			entry.author = content;
		}
		if (
			publishedTimeAttrs.includes(property) ||
			publishedTimeAttrs.includes(name)
		) {
			entry.published = content;
		}
	});

	return entry;
}

function getTimeToRead(text, wordsPerMinute = 300) {
	const words = text.trim().split(/\s+/g).length;
	const minToRead = words / wordsPerMinute;
	const secToRead = Math.ceil(minToRead * 60);
	return secToRead;
}

const blacklistKeys = [
	'CNDID',
	'__twitter_impression',
	'_hsenc',
	'_openstat',
	'action_object_map',
	'action_ref_map',
	'action_type_map',
	'amp',
	'fb_action_ids',
	'fb_action_types',
	'fb_ref',
	'fb_source',
	'fbclid',
	'ga_campaign',
	'ga_content',
	'ga_medium',
	'ga_place',
	'ga_source',
	'ga_term',
	'gs_l',
	'hmb_campaign',
	'hmb_medium',
	'hmb_source',
	'mbid',
	'mc_cid',
	'mc_eid',
	'mkt_tok',
	'referrer',
	'spJobID',
	'spMailingID',
	'spReportId',
	'spUserID',
	'utm_brand',
	'utm_campaign',
	'utm_cid',
	'utm_content',
	'utm_int',
	'utm_mailing',
	'utm_medium',
	'utm_name',
	'utm_place',
	'utm_pubreferrer',
	'utm_reader',
	'utm_social',
	'utm_source',
	'utm_swu',
	'utm_term',
	'utm_userid',
	'utm_viz_id',
	'wt_mc_o',
	'yclid',
	'WT.mc_id',
	'WT.mc_ev',
	'WT.srch',
	'pk_source',
	'pk_medium',
	'pk_campaign',
];

function purifyUrl(url) {
	try {
		const pureUrl = new URL(url);

		blacklistKeys.forEach((key) => {
			pureUrl.searchParams.delete(key);
		});

		return pureUrl.toString().replace(pureUrl.hash, '');
	} catch (err) {
		return null;
	}
}
