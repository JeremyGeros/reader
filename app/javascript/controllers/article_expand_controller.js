import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
	static targets = ['content', 'button'];

	toggle() {
		if (this.element.classList.contains('expanded')) {
			this.contentTarget.classList.remove('h-auto');
			this.element.classList.remove('expanded');
		} else {
			this.contentTarget.classList.add('h-auto');
			this.element.classList.add('expanded');
		}
	}
}
