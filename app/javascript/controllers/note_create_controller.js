import { Controller } from '@hotwired/stimulus';
import { createPopper, showPoppper, hidePopper } from 'utils/popper.js';
import { createNote, deleteNote, updateArticle } from 'utils/api.js';

const blockElements = [
	'p',
	'div',
	'ol',
	'ul',
	'pre',
	'blockquote',
	'h1',
	'h2',
	'h3',
	'h4',
	'h5',
	'h6',
];

function getSelected() {
	if (window.getSelection) {
		return window.getSelection();
	} else if (document.getSelection) {
		return document.getSelection();
	}

	return false;
}

function findNearsetBlockParent(element) {
	let node = element;

	while (node.nodeType === Node.TEXT_NODE) {
		node = node.parentElement;
	}

	while (!blockElements.includes(node.nodeName.toLowerCase())) {
		node = node.parentElement;
	}

	return node;
}

// Recursively find the first block element without children block elements
function findFirstBlockElementWithoutBlockChild(node) {
	if (blockElements.includes(node.nodeName.toLowerCase())) {
		if (node.childNodes.length === 0) {
			return node;
		}

		for (let i = 0; i < node.childNodes.length; i++) {
			const child = node.childNodes[i];
			if (blockElements.includes(child.nodeName.toLowerCase())) {
				return findFirstBlockElementWithoutBlockChild(child);
			}
		}
	}

	return node;
}

const removeHighlightHTML = `
  <span class="remove-highlight flex items-center hover:text-red-400 cursor-pointer py-1">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 mr-1">
      <path stroke-linecap="round" stroke-linejoin="round" d="M14.74 9l-.346 9m-4.788 0L9.26 9m9.968-3.21c.342.052.682.107 1.022.166m-1.022-.165L18.16 19.673a2.25 2.25 0 01-2.244 2.077H8.084a2.25 2.25 0 01-2.244-2.077L4.772 5.79m14.456 0a48.108 48.108 0 00-3.478-.397m-12 .562c.34-.059.68-.114 1.022-.165m0 0a48.11 48.11 0 013.478-.397m7.5 0v-.916c0-1.18-.91-2.164-2.09-2.201a51.964 51.964 0 00-3.32 0c-1.18.037-2.09 1.022-2.09 2.201v.916m7.5 0a48.667 48.667 0 00-7.5 0" />
    </svg>


    Remove Highlight
  </span>
`;

const addHighlightHTML = `
  <span class="add-highlight flex items-center hover:text-gray-300 cursor-pointer py-1">
    <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="w-5 h-5 mr-1">
      <path stroke-linecap="round" stroke-linejoin="round" d="M9.53 16.122a3 3 0 00-5.78 1.128 2.25 2.25 0 01-2.4 2.245 4.5 4.5 0 008.4-2.245c0-.399-.078-.78-.22-1.128zm0 0a15.998 15.998 0 003.388-1.62m-5.043-.025a15.994 15.994 0 011.622-3.395m3.42 3.42a15.995 15.995 0 004.764-4.648l3.876-5.814a1.151 1.151 0 00-1.597-1.597L14.146 6.32a15.996 15.996 0 00-4.649 4.763m3.42 3.42a6.776 6.776 0 00-3.42-3.42" />
    </svg>

    Highlight
  </span>
`;

export default class extends Controller {
	connect() {
		document.addEventListener('selectionchange', this.selectionChanged);
	}

	disconnect() {
		document.removeEventListener('selectionchange', this.selectionChanged);
	}

	wrapRange = (range) => {
		let startNode = range.startContainer;
		let endNode = range.endContainer;

		const span = document.createElement('span');
		span.classList.add('highlighted');

		const inlineElements = ['span', 'a', 'em', 'strong'];

		if (startNode.nodeType === Node.TEXT_NODE) {
			startNode = startNode.parentElement;
		}
		if (inlineElements.includes(startNode.nodeName.toLowerCase())) {
			range.setStartBefore(startNode);
		}

		if (endNode.nodeType === Node.TEXT_NODE) {
			endNode = endNode.parentElement;
		}
		if (inlineElements.includes(endNode.nodeName.toLowerCase())) {
			range.setEndAfter(endNode);
		}

		range.surroundContents(span);

		return span;
	};

	highlight = () => {
		const selectedText = this.selection.toString();
		let node = this.selection.anchorNode;
		while (node.nodeType === Node.TEXT_NODE) {
			node = node.parentElement;
		}

		const selectionRange = this.selection.getRangeAt(0);
		let startNode = selectionRange.startContainer;
		let endNode = selectionRange.endContainer;

		let spans = [];

		if (startNode.parentElement !== endNode.parentElement) {
			let startNode = selectionRange.startContainer;
			let endNode = selectionRange.endContainer;

			let startParent = startNode.parentElement;
			let endParent = endNode.parentElement;

			let startOffset = selectionRange.startOffset;
			let endOffset = selectionRange.endOffset;

			let startRange = document.createRange();
			let endRange = document.createRange();

			startRange.setStart(startNode, startOffset);
			startRange.setEnd(startParent, startParent.childNodes.length);

			endRange.setStart(endParent, 0);
			endRange.setEnd(endNode, endOffset);

			spans.push(this.wrapRange(startRange));

			let parent = startParent.nextElementSibling;
			if (blockElements.includes(parent.nodeName.toLowerCase())) {
				parent = findFirstBlockElementWithoutBlockChild(parent);
			}

			let previousParent = startParent;
			while (parent !== endParent) {
				let range = document.createRange();
				range.setStart(parent, 0);
				range.setEnd(parent, parent.childNodes.length);
				spans.push(this.wrapRange(range));

				while (
					parent.nextElementSibling === null &&
					parent.parentElement !== null
				) {
					parent = parent.parentElement;
				}
				previousParent = parent;
				parent = parent.nextElementSibling;
			}

			if (blockElements.includes(parent.nodeName.toLowerCase())) {
				parent = findFirstBlockElementWithoutBlockChild(parent);
			}

			spans.push(this.wrapRange(endRange));
		} else {
			spans.push(this.wrapRange(selectionRange));
		}

		this.createNote(spans);
	};

	removeHighlight = (event) => {
		const noteNode = findNearsetBlockParent(this.selection.anchorNode);
		const spanId = noteNode.querySelector('.highlighted').id;

		const spans = document.querySelectorAll(`#${spanId}`);
		spans.forEach((span) => {
			const html = span.innerHTML;
			span.outerHTML = html;
		});

		const noteId = spanId.split('-')[1];
		deleteNote(noteId, () => {
			this.saveArticleContents();
		});
	};

	createNote = (spans) => {
		let text = spans.map((span) => span.innerText).join(' ');

		const params = {
			note: {
				article_id: this.element.dataset.id,
				text: text,
			},
		};
		createNote(params, (data) => {
			spans.forEach((span) => (span.id = `note-${data.id}`));
			this.saveArticleContents();
		});
	};

	saveArticleContents = () => {
		const params = {
			id: this.element.dataset.id,
			article: {
				edited_content: this.element.innerHTML,
			},
		};

		updateArticle(params);
	};

	selectionChanged = () => {
		var selection = getSelected();

		if (selection && selection.isCollapsed === false) {
			const noteNode = findNearsetBlockParent(selection.anchorNode);
			if (noteNode && this.element.contains(noteNode)) {
				this.selection = selection;
				this.popper = createPopper(noteNode, 'top');

				if (noteNode.querySelector('.highlighted') !== null) {
					showPoppper(this.popper, removeHighlightHTML);
					this.popper.tooltip
						.querySelectorAll('.remove-highlight')[0]
						.addEventListener('mousedown', this.removeHighlight);
				} else {
					showPoppper(this.popper, addHighlightHTML);
					this.popper.tooltip
						.querySelectorAll('.add-highlight')[0]
						.addEventListener('mousedown', this.highlight);
				}
			}
		} else {
			if (this.popper) {
				hidePopper(this.popper);
				this.popper = null;
			}
		}
	};
}
