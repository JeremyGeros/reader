import { Controller } from '@hotwired/stimulus';
import { updateUser } from 'utils/api';
import hotkeys from 'hotkeys-js';

const fontSizes = ['sm', 'md', 'lg', 'xl'];

export default class extends Controller {
	connect() {
		hotkeys('m', this.toggleTheme);
		hotkeys('n', this.toggleSidebar);
		hotkeys('/', this.toggleKeyboardShortcuts);

		hotkeys('shift+=', this.fontSizeUp);
		hotkeys('shift+-', this.fontSizeDown);
	}

	disconnect() {
		hotkeys.unbind('m');
		hotkeys.unbind('n');
		hotkeys.unbind('shift+=');
		hotkeys.unbind('shift+-');
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

	toggleKeyboardShortcuts = (e) => {
		e.preventDefault();
		document.querySelectorAll('#keyboard-shortcuts').forEach((el) => {
			el.click();
		});
	};

	changeFontSize = (up) => {
		let currentSize;
		if (document.documentElement.classList.contains('content-text-sm')) {
			document.documentElement.classList.remove('content-text-sm');
			currentSize = 'sm';
		} else if (
			document.documentElement.classList.contains('content-text-base')
		) {
			document.documentElement.classList.remove('content-text-base');
			currentSize = 'md';
		} else if (document.documentElement.classList.contains('content-text-lg')) {
			document.documentElement.classList.remove('content-text-lg');
			currentSize = 'lg';
		} else if (document.documentElement.classList.contains('content-text-xl')) {
			document.documentElement.classList.remove('content-text-xl');
			currentSize = 'xl';
		}

		const index = fontSizes.indexOf(currentSize);
		let nextSize;
		if (up) {
			if (index < fontSizes.length - 1) {
				nextSize = fontSizes[index + 1];
			} else {
				nextSize = fontSizes[fontSizes.length - 1];
			}
		} else {
			if (index > 0) {
				nextSize = fontSizes[index - 1];
			} else {
				nextSize = fontSizes[0];
			}
		}

		updateUser({
			user: {
				preferred_font_size: nextSize,
			},
		});

		if (nextSize === 'md') {
			nextSize = 'base';
		}
		document.documentElement.classList.add(`content-text-${nextSize}`);
	};

	fontSizeUp = () => {
		this.changeFontSize(true);
	};

	fontSizeDown = () => {
		this.changeFontSize(false);
	};
}
