// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mermaid from 'astro-mermaid';

export default defineConfig({
	site: 'https://microsoft.github.io',
	base: '/',
	integrations: [
		mermaid(),
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
				baseUrl: 'https://github.com/microsoft/devsquad-copilot/edit/main/docs-site/',
			},
			customCss: ['./src/styles/custom.css'],
			lastUpdated: true,
			sidebar: [
				{ label: 'Home', slug: 'index' },
				{ label: 'Getting Started', slug: 'getting-started' },
				{ label: 'Framework Architecture', slug: 'framework' },
				{
					label: 'Concepts',
					items: [
						{ label: 'Glossary', slug: 'concepts/glossary' },
						{ label: 'Impact Classification', slug: 'concepts/impact-classification', badge: 'Core' },
						{ label: 'Comprehension Checkpoints', slug: 'concepts/comprehension-checkpoints', badge: 'Core' },
						{ label: 'Reasoning and Handoff', slug: 'concepts/reasoning-and-handoff' },
					],
				},
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
					label: 'Delivery Guardrails',
					items: [
						{ label: 'Philosophy', slug: 'delivery-guardrails' },
						{ label: 'Implementation Guardrails', slug: 'guardrails/implementation' },
						{ label: 'Team Coordination', slug: 'guardrails/team-coordination' },
					],
				},
				{
					label: 'Extensibility',
					items: [
						{ label: 'Overview', slug: 'extensibility' },
						{ label: 'Extension Recipes', slug: 'extensibility/recipes', badge: { text: 'New', variant: 'success' } },
					],
				},
				{ label: 'Work Items', slug: 'work-items' },
				{
					label: 'Decisions',
					collapsed: true,
					badge: '12 ADRs',
					autogenerate: { directory: 'decisions' },
				},
				{
					label: 'Reference',
					collapsed: true,
					items: [
						{ label: 'FAQ', slug: 'faq' },
						{ label: 'Troubleshooting', slug: 'troubleshooting' },
						{ label: 'Contributing', slug: 'contributing' },
						{ label: 'Changelog', slug: 'changelog' },
					],
				},
			],
		}),
	],
});
