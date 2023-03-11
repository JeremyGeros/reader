import { Controller } from '@hotwired/stimulus';

const openClasses = [
	'ease-out',
	'duration-100',
	'opacity-0',
	'translate-y-4',
	'sm:translate-y-0',
	'sm:scale-95',
];

const openingClasses = ['opacity-100', 'translate-y-0', 'sm:scale-100'];

export default class extends Controller {
	static targets = ['modal', 'backdrop'];

	open(contentHTML) {
		this.modalTarget.innerHTML = contentHTML;

		this.backdropTarget.classList.remove('hidden');
		this.element.classList.add('open');
		this.modalTarget.classList.add(...openClasses);
		this.element.classList.remove('hidden');
		setTimeout(() => {
			this.modalTarget.classList.add(...openingClasses);
		}, 1);
	}

	close() {
		this.backdropTarget.classList.add('hidden');
		this.element.classList.remove('open');
		this.element.classList.add('hidden');
		this.modalTarget.classList.remove(...openClasses);
		this.modalTarget.classList.remove(...openingClasses);
	}

	closeOnBackdropClick(e) {
		if (this.modalTarget.contains(e.target)) {
			return;
		}

		this.close();
	}
}
