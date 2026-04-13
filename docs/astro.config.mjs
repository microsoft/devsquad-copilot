// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import mermaid from 'astro-mermaid';

export default defineConfig({
site: 'https://microsoft.github.io',
base: '/devsquad-copilot/',
integrations: [
mermaid(),
starlight({
title: 'DevSquad Copilot',
description: 'A GitHub Copilot delivery framework that leverages AI agents to ship at the pace of innovation without sacrificing quality, security, and scalability.',
social: [
{ icon: 'github', label: 'GitHub', href: 'https://github.com/microsoft/devsquad-copilot' },
],
logo: {
dark: './src/assets/logos/devsquad-logo-medium-transparent.png',
light: './src/assets/logos/devsquad-logo-medium-transparent.png',
replacesTitle: false,
},
editLink: {
baseUrl: 'https://github.com/microsoft/devsquad-copilot/edit/main/docs/',
},
head: [
{
tag: 'script',
content: `
(function() {
  var key = 'starlight-sidebar-collapsed';
  var collapsed = localStorage.getItem(key) === 'true';
  if (collapsed) document.documentElement.classList.add('sidebar-collapsed');

  document.addEventListener('DOMContentLoaded', function() {
    if (window.innerWidth < 800) return;
    var sidebar = document.querySelector('.sidebar');
    if (!sidebar) return;

    var btn = document.createElement('button');
    btn.className = 'sidebar-toggle';
    btn.setAttribute('aria-label', 'Toggle sidebar');
    btn.innerHTML = '<svg viewBox="0 0 24 24"><path d="M15.41 7.41 14 6l-6 6 6 6 1.41-1.41L10.83 12z"/></svg>';
    sidebar.parentElement.appendChild(btn);

    btn.addEventListener('click', function() {
      collapsed = !collapsed;
      document.documentElement.classList.toggle('sidebar-collapsed', collapsed);
      localStorage.setItem(key, collapsed);
    });
  });
})();
`,
},
],
customCss: ['./src/styles/custom.css'],
lastUpdated: true,
sidebar: [
{ label: 'Home', slug: 'index' },
{ label: 'How it Works', slug: 'how-it-works' },
{
label: 'Start Here',
collapsed: true,
items: [
{ label: 'Install & First Run', slug: 'getting-started' },
{ label: 'Build a Feature', slug: 'guides/feature-walkthrough' },
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
label: 'Architecture',
collapsed: true,
items: [
{ label: 'Framework Overview', slug: 'framework' },
{ label: 'Decision Records', slug: 'decisions' },
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
],
}),
],
});
