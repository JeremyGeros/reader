import { Controller } from '@hotwired/stimulus';
import { createPopper, showPoppper, hidePopper } from '../utils/popper';

const showEvents = ['mouseenter', 'focus'];
const hideEvents = ['mouseleave', 'blur'];

export default class extends Controller {
	connect() {
		this.popper = createPopper(
			this.element,
			this.element.dataset.tooltipPlacement || 'bottom'
		);

		showEvents.forEach((event) => {
			this.element.addEventListener(event, this.show);
		});

		hideEvents.forEach((event) => {
			this.element.addEventListener(event, this.hide);
		});
	}

	show = () => {
		if (
			!this.element.dataset.tooltipRequiredClass ||
			document.documentElement.classList.contains(
				this.element.dataset.tooltipRequiredClass
			)
		) {
			showPoppper(this.popper, this.element.dataset.tooltip);
		}
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
