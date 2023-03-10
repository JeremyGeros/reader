import { Controller } from '@hotwired/stimulus';
import { updateUser } from 'utils/api.js';
import hotkeys from 'hotkeys-js';

export default class extends Controller {
	connect() {
		hotkeys('m', this.toggleTheme);
		hotkeys('n', this.toggleSidebar);
	}

	disconnect() {
		hotkeys.unbind('m');
		hotkeys.unbind('n');
	}

	toggleTheme = () => {
		document;
		const newTheme = document.documentElement.classList.contains('dark')
			? 'light'
			: 'dark';
		updateUser({
			user: {
				preferred_theme: newTheme,
			},
		});
		document.documentElement.classList.toggle('dark');
	};

	toggleSidebar = () => {
		const isCollapsed =
			document.documentElement.classList.contains('sidebar-collapsed');

		updateUser({
			user: {
				sidebar_collapsed: !isCollapsed,
			},
		});

		document.documentElement.classList.toggle('sidebar-collapsed');
	};
}
