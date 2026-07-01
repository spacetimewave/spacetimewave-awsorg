# Spacetimewave AWS Organization

This repository creates and manages **spacetimewave** AWS infrastructure: AWS Organization, Organizational Units, AWS sub-accounts and IAM.

## Repository

The repository structure is the following:

```
spacetimewave-awsorg
├── .claude
│   └── ...
├── .github
│   └── workflows
│       ├── infrastructure.pipeline.yml
│       └── ...
├── docs
│   └── ...
|
├── infrastructure
│   ├── .terraform
│   |   └── ...
|   |
│   ├── modules
│   |   └── ...
|   |
│   └── ...
```

- The infrastructure uses OpenTofu and AWS, and all its code is in the "/infrastructure" folder.

- The infrastructure pipeline is a GitHub Action under the "/.github/workflows" folder.