import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
	static outlets = ['modal'];
	static targets = ['content'];

	open() {
		this.modalOutlet.open(this.contentTarget.innerHTML);
	}
}
