const defaultTheme = require('tailwindcss/defaultTheme');
const plugin = require('tailwindcss/plugin');

module.exports = {
	content: [
		'./public/*.html',
		'./app/helpers/**/*.rb',
		'./app/javascript/**/*.js',
		'./app/views/**/*.{erb,haml,html,slim}',
	],
	safelist: [
		{
			pattern: /w-\d+/,
		},
		{
			pattern: /h-\d+/,
		},
	],
	theme: {
		extend: {
			fontFamily: {
				sans: ['Whitney A', 'Whitney B', ...defaultTheme.fontFamily.sans],
				serif: ['Sentinel A', 'Sentinel B', ...defaultTheme.fontFamily.serif],
			},

			colors: {},

			textShadow: {
				sm: '0 1px 2px var(--tw-shadow-color)',
				DEFAULT: '0 2px 4px var(--tw-shadow-color)',
				lg: '0 8px 16px var(--tw-shadow-color)',
			},

			keyframes: {
				'bounce-right': {
					'0%, 100%': {
						transform: 'translateX(0)',
						'animation-timing-function': 'cubic-bezier(0.8, 0, 1, 1)',
					},
					'50%': {
						transform: 'translateX(25%)',
						'animation-timing-function': 'cubic-bezier(0, 0, 0.2, 1)',
					},
				},
			},

			animation: {
				'bounce-right': 'bounce-right infinite 1s',
			},
		},
	},
	plugins: [
		require('@tailwindcss/forms'),
		require('@tailwindcss/aspect-ratio'),
		require('@tailwindcss/typography'),
		require('@tailwindcss/line-clamp'),
		plugin(function ({ matchUtilities, theme }) {
			matchUtilities(
				{
					'text-shadow': (value) => ({
						textShadow: value,
					}),
				},
				{ values: theme('textShadow') }
			);
		}),
	],
};
