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
description: 'A GitHub Copilot delivery framework — leverage AI agents to ship at the pace of innovation without sacrificing quality, security, and scalability.',
social: [
{ icon: 'github', label: 'GitHub', href: 'https://github.com/microsoft/devsquad-copilot' },
],
logo: {
dark: './src/assets/logos/devsquad-logo-medium-transparent.png',
light: './src/assets/logos/devsquad-logo-medium-transparent.png',
replacesTitle: false,
},
editLink: {
baseUrl: 'https://github.com/microsoft/devsquad-copilot/edit/main/docs-site/',
},
customCss: ['./src/styles/custom.css'],
lastUpdated: true,
sidebar: [
{ label: 'Home', slug: 'index' },
{
label: 'Start Here',
items: [
{ label: 'Install & First Run', slug: 'getting-started', badge: { text: '1', variant: 'success' } },
{ label: 'Build a Feature', slug: 'guides/feature-walkthrough', badge: { text: '2', variant: 'success' } },
{ label: 'How It Works', slug: 'framework', badge: { text: '3', variant: 'success' } },
],
},
{
label: 'Guardrails',
collapsed: true,
items: [
{ label: 'Philosophy & Approach', slug: 'delivery-guardrails' },
{ label: 'Impact Classification', slug: 'concepts/impact-classification', badge: { text: 'Core', variant: 'tip' } },
{ label: 'Comprehension Checkpoints', slug: 'concepts/comprehension-checkpoints', badge: { text: 'Core', variant: 'tip' } },
{ label: 'Implementation Rules', slug: 'guardrails/implementation' },
{ label: 'Team Coordination', slug: 'guardrails/team-coordination' },
],
},
{
label: 'Agents',
collapsed: true,
items: [
{ label: 'Overview', slug: 'agents/overview' },
{ label: 'Conductor', slug: 'agents/conductor' },
{ label: 'Delivery Agents', slug: 'agents/lifecycle' },
{ label: 'Support Agents', slug: 'agents/support' },
],
},
{
label: 'Skills',
collapsed: true,
items: [
{ label: 'Overview', slug: 'skills' },
{ label: 'Plan & Architecture', slug: 'skills/architecture' },
{ label: 'Work Items & Estimation', slug: 'skills/work-items' },
{ label: 'Quality & Security', slug: 'skills/quality' },
{ label: 'Development', slug: 'skills/development' },
{ label: 'Project Setup', slug: 'skills/initialization' },
],
},
{
label: 'Components',
collapsed: true,
items: [
{ label: 'Work Items', slug: 'work-items' },
{ label: 'Custom Instructions', slug: 'core-components/instructions' },
{ label: 'Automation Hooks', slug: 'core-components/hooks' },
{ label: 'Tool Servers', slug: 'core-components/mcp-servers' },
{ label: 'Context Management', slug: 'core-components/context-management' },
{ label: 'Reasoning & Handoff', slug: 'concepts/reasoning-and-handoff' },
],
},
{
label: 'Extend',
collapsed: true,
items: [
{ label: 'Extension Overview', slug: 'extensibility' },
{ label: 'Choose an Extension', slug: 'core-components/comparison' },
{ label: 'Recipes', slug: 'extensibility/recipes', badge: { text: 'New', variant: 'note' } },
],
},
{
label: 'Reference',
collapsed: true,
items: [
{ label: 'Glossary', slug: 'concepts/glossary' },
{ label: 'FAQ', slug: 'faq' },
{ label: 'Troubleshooting', slug: 'troubleshooting' },
{ label: 'Contributing', slug: 'contributing' },
{ label: 'Changelog', slug: 'changelog' },
],
},
{
label: 'Architecture Decisions',
collapsed: true,
autogenerate: { directory: 'decisions' },
},
],
}),
],
});
