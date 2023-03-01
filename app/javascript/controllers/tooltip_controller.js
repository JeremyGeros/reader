import { Controller } from '@hotwired/stimulus';
import { createPopper } from '../popper';

export default class extends Controller {
	connect() {
		createPopper(this.element, this.element.dataset.tooltip);
	}
}
