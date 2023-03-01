export function createPopper(button, tooltip_content) {
	const tooltip = document.querySelector('#tooltip');

	const popperInstance = Popper.createPopper(button, tooltip, {
		modifiers: [
			{
				name: 'offset',
				options: {
					offset: [0, 8],
				},
			},
		],
	});

	function show() {
		tooltip.querySelectorAll('#tooltip-content')[0].innerHTML = tooltip_content;
		// Make the tooltip visible
		tooltip.setAttribute('data-show', '');

		// Enable the event listeners
		popperInstance.setOptions((options) => ({
			...options,
			modifiers: [
				...options.modifiers,
				{ name: 'eventListeners', enabled: true },
			],
		}));

		// Update its position
		popperInstance.update();
	}

	function hide() {
		// Hide the tooltip
		tooltip.removeAttribute('data-show');

		// Disable the event listeners
		popperInstance.setOptions((options) => ({
			...options,
			modifiers: [
				...options.modifiers,
				{ name: 'eventListeners', enabled: false },
			],
		}));
	}

	const showEvents = ['mouseenter', 'focus'];
	const hideEvents = ['mouseleave', 'blur'];

	showEvents.forEach((event) => {
		button.addEventListener(event, show);
	});

	hideEvents.forEach((event) => {
		button.addEventListener(event, hide);
	});
}
