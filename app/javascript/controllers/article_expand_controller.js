import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
	static targets = ['content', 'button'];

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

		if (this.element.classList.contains('read')) {
			setTimeout(() => {
				this.updateArticle({
					id: this.element.dataset.id,
					article: { read_status: 'new' },
				});
				this.element.classList.remove('read');
			}, 0);
		}
	}

	updateArticle(params) {
		fetch(`/articles/${params.id}`, {
			method: 'PATCH',
			headers: {
				'Content-Type': 'application/json',
				Accept: 'application/json',
				'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
					.content,
			},
			body: JSON.stringify(params),
		});
	}
}
