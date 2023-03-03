export function createPopper(button, placement = 'auto') {
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
		placement,
	});

	return { tooltip, popperInstance };
}

export function showPoppper({ tooltip, popperInstance }, tooltip_content) {
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

export function hidePopper({ tooltip, popperInstance }) {
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
