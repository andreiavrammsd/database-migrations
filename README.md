# Database migrations

A setup to run database migrations

## Setup

#### Prerequisites
- You must write [migration files in a proper format](https://github.com/golang-migrate/migrate/blob/master/MIGRATIONS.md)
- Migration files should be stored in a git repository for better management (you can change storage as you wish); Github and Bitbucket will work by default, others need to be adapted
- You need SSH access to repository
- This setup gets database connection info from [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/) (adapt as you wish) 
- Docker is required (all setup presented in [Dockerfile](Dockerfile) can be executed directly on the machine if preferred)
- [Make](http://man7.org/linux/man-pages/man1/make.1.html) is required
- Your deploy system should access the machine this tool is installed on and trigger the migration

#### Build Docker image
```
make build \
    AWS_ACCESS_KEY_ID=awsaccesskeyid \
    AWS_SECRET_ACCESS_KEY=awssecretaccesskey \
    AWS_REGION=eu-central-1 \
    AWS_SECRET_ID=awssecretsid \
    REPOSITORY=git@bitbucket.org:andreiavrammsd/project.git \
    BRANCH=master \
    MIGRATIONS_DIR=migrations \
    PRIVATE_KEY_PATH=~/.ssh/id_rsa
```

AWS access credentials and secrets identifier
- AWS_ACCESS_KEY_ID
- AWS_SECRET_ACCESS_KEY
- AWS_REGION
- AWS_SECRET_ID

Repository containing the migrations, with the branch name, and the directory where the migrations files are in the repository
- REPOSITORY
- BRANCH
- MIGRATIONS_DIR

Local path to private key for repository access
- PRIVATE_KEY_PATH

#### Start/stop container
- make start
- make stop

#### Remove image
- make clean

## Perform migrations
- Run "up" migrations: make up
- Run "down" migrations with step (numer of migrations to revert): make down steps=1
