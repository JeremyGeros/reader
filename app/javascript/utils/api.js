function getHeaders() {
	return {
		'Content-Type': 'application/json',
		Accept: 'application/json',
		'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
	};
}

// ARTICLES API
export function updateArticle(params, callback) {
	fetch(`/articles/${params.id}`, {
		method: 'PATCH',
		headers: {
			'Content-Type': 'application/json',
			Accept: 'application/json',
			'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
		},
		body: JSON.stringify(params),
	})
		.then((response) => response.json())
		.then((data) => {
			if (callback) {
				callback(data);
			}
		});
}

// NOTES API
export function createNote(params, callback) {
	fetch('/notes', {
		method: 'POST',
		headers: getHeaders(),
		body: JSON.stringify(params),
	})
		.then((response) => response.json())
		.then((data) => {
			if (callback) {
				callback(data);
			}
		});
}

export function deleteNote(id, callback) {
	fetch(`/notes/${id}`, {
		method: 'DELETE',
		headers: getHeaders(),
	})
		.then((response) => response.json())
		.then((data) => {
			if (callback) {
				callback(data);
			}
		});
}

// USERS API
export function updateUser(params, callback) {
	fetch(`/users/${params.id}`, {
		method: 'PATCH',
		headers: getHeaders(),
		body: JSON.stringify(params),
	})
		.then((response) => response.json())
		.then((data) => {
			if (callback) {
				callback(data);
			}
		});
}
