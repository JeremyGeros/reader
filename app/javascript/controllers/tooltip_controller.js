import { Controller } from '@hotwired/stimulus';
import { createPopper, showPoppper, hidePopper } from '../popper';

const showEvents = ['mouseenter', 'focus'];
const hideEvents = ['mouseleave', 'blur'];

export default class extends Controller {
	connect() {
		this.popper = createPopper(this.element);

		showEvents.forEach((event) => {
			this.element.addEventListener(event, this.show);
		});

		hideEvents.forEach((event) => {
			this.element.addEventListener(event, this.hide);
		});
	}

	show = () => {
		showPoppper(this.popper, this.element.dataset.tooltip);
	};

	hide = () => {
		hidePopper(this.popper);
	};

	disconnect() {
		showEvents.forEach((event) => {
			this.element.removeEventListener(event, this.show);
		});

		hideEvents.forEach((event) => {
			this.element.removeEventListener(event, this.hide);
		});
	}
}
