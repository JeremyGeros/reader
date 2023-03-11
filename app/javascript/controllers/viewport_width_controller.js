import { Controller } from '@hotwired/stimulus';
import { updateUser } from 'utils/api';
import hotkeys from 'hotkeys-js';

const sizes = ['small', 'medium', 'large', 'xlarge', 'full'];

export default class extends Controller {
	static values = { size: String };

	connect() {
		hotkeys('-', this.minus);
		hotkeys('=', this.plus);
	}

	disconnect() {
		hotkeys.unbind('-');
		hotkeys.unbind('=');
	}

	removeAllSizes() {
		sizes.forEach((size) => {
			document.documentElement.classList.remove(`size-${size}`);
		});
	}

	minus = () => {
		const size = this.sizeValue;
		const index = sizes.indexOf(size);
		if (index > 0) {
			this.sizeValue = sizes[index - 1];
		} else {
			this.sizeValue = sizes[0];
		}

		this.setSize(this.sizeValue);
	};

	plus = () => {
		const size = this.sizeValue;
		const index = sizes.indexOf(size);
		if (index < sizes.length - 1) {
			this.sizeValue = sizes[index + 1];
		} else {
			this.sizeValue = sizes[sizes.length - 1];
		}

		this.setSize(this.sizeValue);
	};

	auto() {
		this.sizeValue = 'medium';
		this.setSize('medium');
	}

	setSize(size) {
		updateUser({
			user: {
				preferred_size: size,
			},
		});
		this.removeAllSizes();
		document.documentElement.classList.add(`size-${size}`);
	}
}
