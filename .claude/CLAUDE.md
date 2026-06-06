# Spacetimewave AWS Organization

This repository creates and manages **spacetimewave** AWS infrastructure: AWS Organization, sub-accounts and IAM.

## Repository

The mono-repository structure is the following:

```
montajes-lucho
├── .github
│   └── infrastructure.pipeline.yml
└── infrastructure
    └── ...
```

- The infrastructure uses OpenTofu and AWS, and all its code is in the "/infrastructure" folder.

- The infrastructure pipeline is a GitHub Action under the "/.github" folder.