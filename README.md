# Gemini CLI Agents

A collection of specialized AI agents for the Gemini CLI, designed to streamline software development workflows. These agents can be installed into any project to provide expert assistance in specific domains (Backend, Frontend, DevOps, QA, etc.).

## 🚀 Quick Install

### Install ALL agents (Default)
Run this command in your project root to install every available agent:
```bash
curl -fsSL https://raw.githubusercontent.com/MillerQuintero-Sol/gemini-cli-agents/main/install.sh | bash
```

### Install Specific agents
If you only need some agents, specify them with flags. Use `--force` to overwrite existing files:
```bash
curl -fsSL https://raw.githubusercontent.com/MillerQuintero-Sol/gemini-cli-agents/main/install.sh | bash -s -- --frontend-react --backend-django-drf --force
```

## 📦 Available Agents

| Agent Flag | Description |
|-------|-------------|
| `--architect-agent` | System design, ADRs, Code Quality |
| `--backend-django` | Django Backend (Monolith/SSR) |
| `--backend-django-drf` | Django REST Framework Backend (API) |
| `--backend-nodejs` | Node.js Backend (TypeScript, Express) |
| `--devops-docker` | Docker & Docker Compose workflows |
| `--frontend-react` | React + TypeScript Frontend |
| `--fullstack-django` | Fullstack Django (DTL + HTMX) |
| `--pm-agent` | Product Management & Requirements |
| `--qa-backend-django-drf` | QA for Django/DRF (Pytest) |
| `--qa-frontend-react` | QA for React (RTL, Playwright) |
| `--uxui-agent` | UX/UI Design & Wireframing |

## 🛠️ Manual Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/MillerQuintero-Sol/gemini-cli-agents.git
   ```
2. Run the installer locally:
   ```bash
   cd gemini-cli-agents
   ./install.sh
   ```

## 🤝 Contributing

Feel free to submit Pull Requests to add new agents or improve existing ones.
