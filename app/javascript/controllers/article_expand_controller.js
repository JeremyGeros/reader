import { Controller } from '@hotwired/stimulus';
import { updateArticle } from '../utils/api';

export default class extends Controller {
	static targets = ['content', 'button'];

	static values = {
		read: Boolean,
		page: String,
	};

	toggle() {
		if (this.element.classList.contains('expanded')) {
			this.element.classList.remove('expanded');
		} else {
			this.element.classList.add('expanded');
		}
	}

	readAndNext(e) {
		e.preventDefault();

		if (this.element.classList.contains('expanded')) {
			setTimeout(() => {
				this.updateArticle({
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
	}

	undoRead(e) {
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
	}
}
