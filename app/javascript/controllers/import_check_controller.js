import { Controller } from '@hotwired/stimulus';

export default class extends Controller {
	static get values() {
		return {
			import: Number,
		};
	}

	connect() {
		clearTimeout(this.importCheckTimeout);
		this.importCheckTimeout = setTimeout(() => {
			this.checkStatus();
		}, 1000);
	}

	checkStatus() {
		clearTimeout(this.importCheckTimeout);
		fetch(`/imports/${this.importValue}/status`, {
			method: 'GET',
			headers: {
				'Content-Type': 'application/json',
				'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')
					.content,
			},
		})
			.then((response) => {
				if (response.ok) {
					response.json().then((data) => {
						if (data.status === 'complete') {
							window.location.reload();
							return;
						} else {
							setTimeout(() => {
								this.checkStatus();
							}, 1000);
						}
					});
				}
			})
			.catch((error) => {
				console.log(error);
			});
	}

	disconnect() {
		clearTimeout(this.importCheckTimeout);
	}
}
