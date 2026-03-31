// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

export default defineConfig({
	site: 'https://microsoft.github.io',
	base: '/',
	integrations: [
		starlight({
			title: 'DevSquad Copilot',
			description: 'A GitHub Copilot delivery framework with guardrails for Spec-Driven Development.',
			social: [
				{ icon: 'github', label: 'GitHub', href: 'https://github.com/microsoft/devsquad-copilot' },
			],
			logo: {
				dark: './src/assets/overview.png',
				light: './src/assets/overview.png',
				replacesTitle: false,
			},
			editLink: {
				baseUrl: 'https://github.com/microsoft/devsquad-copilot/edit/main/site/',
			},
			customCss: ['./src/styles/custom.css'],
			lastUpdated: true,
			sidebar: [
				{ label: 'Home', slug: 'index' },
				{ label: 'Getting Started', slug: 'getting-started' },
				{ label: 'Framework Architecture', slug: 'framework' },
				{
					label: 'Agents',
					items: [
						{ label: 'Overview', slug: 'agents/overview' },
						{ label: 'Conductor (devsquad)', slug: 'agents/conductor' },
						{ label: 'Lifecycle Agents', slug: 'agents/lifecycle' },
						{ label: 'Support Agents', slug: 'agents/support' },
					],
				},
				{ label: 'Skills', slug: 'skills' },
				{
					label: 'Core Components',
					items: [
						{ label: 'Instructions', slug: 'core-components/instructions' },
						{ label: 'Hooks', slug: 'core-components/hooks' },
						{ label: 'MCP Servers', slug: 'core-components/mcp-servers' },
						{ label: 'Context Management', slug: 'core-components/context-management' },
					],
				},
				{
					label: 'Decisions',
					collapsed: true,
					autogenerate: { directory: 'decisions' },
				},
				{ label: 'Extensibility', slug: 'extensibility' },
				{ label: 'Delivery Guardrails', slug: 'delivery-guardrails' },
				{ label: 'Work Items', slug: 'work-items' },
				{ label: 'Troubleshooting', slug: 'troubleshooting' },
				{ label: 'Contributing', slug: 'contributing' },
				{ label: 'Changelog', slug: 'changelog' },
			],
		}),
	],
});
