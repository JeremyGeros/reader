import { Controller } from '@hotwired/stimulus';

const openClasses = [
	'transition',
	'ease-out',
	'duration-100',
	'transform',
	'opacity-0',
	'scale-95',
];

const openingClasses = ['transform', 'opacity-100', 'scale-100'];

export default class extends Controller {
	static get targets() {
		return ['dropdown', 'overlay'];
	}

	toggleDropdown() {
		if (this.element.classList.contains('open')) {
			this.closeDropdown();
		} else {
			this.openDropwdown();
		}
	}

	openDropwdown() {
		this.overlayTarget.classList.remove('hidden');
		this.element.classList.add('open');
		this.dropdownTarget.classList.add(...openClasses);
		this.dropdownTarget.classList.remove('hidden');
		setTimeout(() => {
			this.dropdownTarget.classList.add(...openingClasses);
		}, 1);
	}

	closeDropdown() {
		this.overlayTarget.classList.add('hidden');
		this.element.classList.remove('open');
		this.dropdownTarget.classList.add('hidden');
		this.dropdownTarget.classList.remove(...openClasses);
		this.dropdownTarget.classList.remove(...openingClasses);
	}
}
