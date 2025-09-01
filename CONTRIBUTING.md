# Contributing to AgentFoundry

🎉 Thank you for your interest in contributing to AgentFoundry! This document provides guidelines and information for contributors.

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Issue Reporting](#issue-reporting)
- [Development Standards](#development-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Community](#community)

## 🤝 Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before contributing.

### Our Pledge

We are committed to making participation in our project a harassment-free experience for everyone, regardless of:
- Age, body size, disability, ethnicity, gender identity and expression
- Level of experience, nationality, personal appearance, race, religion
- Sexual identity and orientation

### Expected Behavior

- **Be respectful** and inclusive in all interactions
- **Be collaborative** and help others learn and grow
- **Be constructive** when giving feedback
- **Be patient** with newcomers and different skill levels

## 🚀 Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Git** installed and configured
- **Python 3.8+** and **Node.js 16+**
- **Docker** and **Docker Compose**
- **Make** utility
- Basic understanding of the project architecture

### First-Time Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/YOUR_USERNAME/AgentFoundry.git
   cd AgentFoundry
   ```

2. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/AgentFoundry.git
   ```

3. **Set up development environment**
   ```bash
   # Run initialization script
   ./scripts/init.sh
   
   # Or manual setup
   make install
   ./scripts/setup-env.sh --env development --interactive
   ```

4. **Verify setup**
   ```bash
   make test
   ./scripts/health-check.sh
   ```

## 🛠️ Development Setup

### Environment Configuration

```bash
# Copy environment template
cp .env.example .env

# Edit configuration
vim .env
```

### Required Environment Variables

```bash
# Core Configuration
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=debug

# Database
DATABASE_URL=postgresql://user:pass@localhost:5432/agentfoundry_dev
REDIS_URL=redis://localhost:6379/0

# API Keys (for testing)
OPENAI_API_KEY=your_test_key_here
ANTHROPIC_API_KEY=your_test_key_here

# Security
SECRET_KEY=your_development_secret_key
JWT_SECRET=your_jwt_secret
```

### Development Commands

```bash
# Start development environment
make dev

# Run tests
make test
make test-golden
make test-redteam

# Code quality
make lint
make format
make security-scan

# Documentation
make docs
make docs-serve
```

## 📝 Contributing Guidelines

### Types of Contributions

We welcome various types of contributions:

- 🐛 **Bug fixes**
- ✨ **New features**
- 📚 **Documentation improvements**
- 🧪 **Test coverage**
- 🔧 **Performance optimizations**
- 🎨 **UI/UX improvements**
- 🌐 **Internationalization**

### Contribution Workflow

1. **Check existing issues** before starting work
2. **Create or comment** on an issue to discuss your idea
3. **Fork and create** a feature branch
4. **Implement** your changes with tests
5. **Submit** a pull request

### Branch Naming Convention

```bash
# Feature branches
feature/agent-role-enhancement
feature/new-evaluation-metrics

# Bug fix branches
bugfix/memory-leak-orchestration
bugfix/auth-timeout-issue

# Documentation branches
docs/api-reference-update
docs/setup-guide-improvement

# Hotfix branches (for urgent production fixes)
hotfix/security-vulnerability-fix
```

### Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```bash
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `perf`: Performance improvements
- `ci`: CI/CD changes

#### Examples
```bash
feat(agents): add new data analysis agent role

fix(auth): resolve token expiration handling

docs(readme): update installation instructions

test(eval): add golden test cases for new features

refactor(orchestration): improve agent routing logic
```

## 🔄 Pull Request Process

### Before Submitting

1. **Update your branch**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run quality checks**
   ```bash
   make lint
   make test
   make security-scan
   ```

3. **Update documentation** if needed

4. **Add tests** for new functionality

### PR Requirements

- ✅ **Clear description** of changes and motivation
- ✅ **Tests pass** and coverage maintained
- ✅ **Documentation updated** for user-facing changes
- ✅ **No merge conflicts** with main branch
- ✅ **Follows coding standards** and style guide
- ✅ **Security considerations** addressed

### PR Template

```markdown
## Description
Brief description of changes and motivation.

## Type of Change
- [ ] Bug fix (non-breaking change)
- [ ] New feature (non-breaking change)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Golden tests updated/added
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] Tests added/updated
- [ ] No breaking changes (or clearly documented)

## Screenshots (if applicable)
[Add screenshots for UI changes]

## Additional Notes
[Any additional information or context]
```

### Review Process

1. **Automated checks** run on PR submission
2. **Code review** by maintainers
3. **Testing** in staging environment
4. **Approval** and merge by maintainers

## 🐛 Issue Reporting

### Bug Reports

When reporting bugs, please include:

- **Clear title** and description
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Environment details** (OS, Python version, etc.)
- **Error messages** and stack traces
- **Screenshots** if applicable

### Feature Requests

For feature requests, please provide:

- **Clear description** of the feature
- **Use case** and motivation
- **Proposed implementation** (if any)
- **Alternatives considered**
- **Additional context**

### Issue Templates

We provide issue templates for:
- 🐛 Bug reports
- ✨ Feature requests
- 📚 Documentation improvements
- ❓ Questions and support

## 🏗️ Development Standards

### Code Style

#### Python
- **PEP 8** compliance
- **Black** for formatting
- **isort** for import sorting
- **Type hints** for all functions
- **Docstrings** for all public methods

```python
def process_agent_request(
    request: AgentRequest,
    context: Optional[Dict[str, Any]] = None
) -> AgentResponse:
    """Process an agent request with optional context.
    
    Args:
        request: The agent request to process
        context: Optional context for processing
        
    Returns:
        The processed agent response
        
    Raises:
        ValidationError: If request is invalid
    """
    # Implementation here
    pass
```

#### JavaScript/TypeScript
- **ESLint** and **Prettier** configuration
- **TypeScript** for type safety
- **JSDoc** comments for documentation

```typescript
/**
 * Process agent configuration data
 * @param config - The agent configuration
 * @param options - Processing options
 * @returns Promise resolving to processed config
 */
async function processAgentConfig(
  config: AgentConfig,
  options?: ProcessingOptions
): Promise<ProcessedConfig> {
  // Implementation here
}
```

### Architecture Principles

- **Separation of concerns**
- **Dependency injection**
- **Interface-based design**
- **Error handling and logging**
- **Security by design**
- **Performance considerations**

### Security Guidelines

- **Input validation** for all user inputs
- **Output sanitization** for all outputs
- **Authentication** and **authorization** checks
- **Secure configuration** management
- **Dependency vulnerability** scanning
- **Security testing** integration

## 🧪 Testing Guidelines

### Test Structure

```
tests/
├── unit/                 # Unit tests
├── integration/          # Integration tests
├── e2e/                 # End-to-end tests
├── golden/              # Golden test cases
├── redteam/             # Security tests
└── fixtures/            # Test data and fixtures
```

### Test Categories

#### Unit Tests
- **Fast execution** (<1s per test)
- **Isolated** functionality testing
- **High coverage** (>90% for new code)
- **Mocked dependencies**

#### Integration Tests
- **Component interaction** testing
- **Database integration**
- **API endpoint testing**
- **Service communication**

#### Golden Tests
- **Quality assurance** for core functionality
- **Regression prevention**
- **Performance benchmarking**
- **User scenario validation**

#### Red Team Tests
- **Security vulnerability** testing
- **Attack simulation**
- **Data protection** validation
- **Access control** testing

### Test Writing Guidelines

```python
import pytest
from unittest.mock import Mock, patch

class TestAgentOrchestration:
    """Test suite for agent orchestration functionality."""
    
    def setup_method(self):
        """Set up test fixtures before each test method."""
        self.orchestrator = AgentOrchestrator()
        self.mock_agent = Mock(spec=Agent)
    
    def test_agent_selection_by_keyword(self):
        """Test agent selection based on keywords."""
        # Arrange
        request = AgentRequest(keywords=["data", "analysis"])
        
        # Act
        selected_agent = self.orchestrator.select_agent(request)
        
        # Assert
        assert selected_agent.role == "data_analyst"
        assert selected_agent.capabilities.includes("analysis")
    
    @patch('agentfoundry.services.external_api')
    def test_external_api_integration(self, mock_api):
        """Test integration with external APIs."""
        # Arrange
        mock_api.return_value = {"status": "success", "data": {}}
        
        # Act
        result = self.orchestrator.call_external_service()
        
        # Assert
        mock_api.assert_called_once()
        assert result["status"] == "success"
```

## 📚 Documentation

### Documentation Types

- **API Documentation**: Auto-generated from code
- **User Guides**: Step-by-step instructions
- **Developer Guides**: Technical implementation details
- **Architecture Docs**: System design and decisions
- **Runbooks**: Operational procedures

### Documentation Standards

- **Clear and concise** writing
- **Code examples** for all features
- **Screenshots** for UI features
- **Version-specific** information
- **Regular updates** with code changes

### Writing Guidelines

1. **Use active voice** and present tense
2. **Include code examples** that work
3. **Provide context** and motivation
4. **Link to related** documentation
5. **Keep it up-to-date** with code changes

## 🌟 Recognition

### Contributor Recognition

We recognize contributors through:

- **Contributors list** in README
- **Release notes** acknowledgments
- **GitHub achievements** and badges
- **Community highlights**

### Becoming a Maintainer

Regular contributors may be invited to become maintainers based on:

- **Consistent quality** contributions
- **Community involvement** and helpfulness
- **Technical expertise** and judgment
- **Alignment** with project values

## 🆘 Getting Help

### Support Channels

- **GitHub Issues**: Bug reports and feature requests
- **GitHub Discussions**: Questions and community support
- **Documentation**: Comprehensive guides and references
- **Code Comments**: Inline documentation and examples

### Maintainer Contact

For urgent issues or private concerns:
- **Email**: maintainers@agentfoundry.dev
- **Security Issues**: security@agentfoundry.dev

## 📄 License

By contributing to AgentFoundry, you agree that your contributions will be licensed under the same [MIT License](LICENSE) that covers the project.

---

**Thank you for contributing to AgentFoundry! 🚀**

Your contributions help make AI agent orchestration more accessible and powerful for everyone. We appreciate your time, effort, and expertise in making this project better.

For questions about contributing, please don't hesitate to reach out through our support channels or create an issue for discussion.