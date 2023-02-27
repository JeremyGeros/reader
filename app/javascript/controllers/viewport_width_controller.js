import { Controller } from '@hotwired/stimulus';

const sizes = ['small', 'medium', 'large', 'xlarge', 'full'];

export default class extends Controller {
	static values = { size: String };

	removeAllSizes() {
		document.querySelectorAll('.article-width').forEach((article) => {
			sizes.forEach((size) => {
				article.classList.remove(size);
			});
		});

		sizes.forEach((size) => {
			this.element.classList.remove(size);
		});
	}

	minus() {
		const size = this.sizeValue;
		const index = sizes.indexOf(size);
		if (index > 0) {
			this.sizeValue = sizes[index - 1];
		} else {
			this.sizeValue = sizes[0];
		}

		this.setSize(this.sizeValue);
	}

	plus() {
		const size = this.sizeValue;
		const index = sizes.indexOf(size);
		if (index < sizes.length - 1) {
			this.sizeValue = sizes[index + 1];
		} else {
			this.sizeValue = sizes[sizes.length - 1];
		}

		this.setSize(this.sizeValue);
	}

	auto() {
		this.sizeValue = 'medium';
		this.setSize('medium');
	}

	setSize(size) {
		this.removeAllSizes();
		document.querySelectorAll('.article-width').forEach((article) => {
			article.classList.add(size);
		});
		this.element.classList.add(size);
	}
}
