import { Controller } from '@hotwired/stimulus';
import { updateArticle } from 'utils/api';
import hotkeys from 'hotkeys-js';

export default class extends Controller {
	static targets = ['content', 'button'];

	static values = {
		read: Boolean,
		page: String,
	};

	connect() {
		hotkeys('k', this.readAndNext);
		// hotkeys('k', this.readAndPrevious);
	}

	disconnect() {
		hotkeys.unbind('k');
		// hotkeys.unbind('k');
	}

	toggle() {
		if (this.element.classList.contains('expanded')) {
			this.element.classList.remove('expanded');
		} else {
			this.element.classList.add('expanded');
		}
	}

	readAndNext = (e) => {
		e.preventDefault();

		if (this.element.classList.contains('expanded')) {
			setTimeout(() => {
				updateArticle({
					id: this.element.dataset.id,
					article: { read_status: 'read' },
				});
				this.toggle();
				this.element.classList.add('read');
				this.element.nextElementSibling
					?.querySelector('.expand-button')
					?.click();
				this.element.nextElementSibling?.scrollIntoView();
			}, 0);
		}
	};

	undoRead = (e) => {
		e.preventDefault();

		if (this.readValue === true) {
			setTimeout(() => {
				updateArticle({
					id: this.element.dataset.id,
					article: { read_status: 'new' },
				});
				this.element.classList.remove('read');
				console.log(this.pageValue);
				if (this.pageValue === 'read') {
					this.element.remove();
				}
			}, 0);
		}
	};
}
