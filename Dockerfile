FROM centos:7

WORKDIR /src

ARG AWS_ACCESS_KEY_ID
ARG AWS_SECRET_ACCESS_KEY
ARG AWS_REGION
ARG AWS_SECRET_ID
ARG REPOSITORY
ARG BRANCH
ARG MIGRATIONS_DIR
ARG PRIVATE_KEY_FILE
ARG MIGRATE_VERSION

# Install extra packages where the required tools are found (https://fedoraproject.org/wiki/EPEL)
RUN yum -y update && yum -y install epel-release

# Install and configure AWS cli tool to access secrets manager
RUN yum -y install python-pip && pip install --upgrade pip && pip install awscli
RUN printf "$AWS_ACCESS_KEY_ID\n$AWS_SECRET_ACCESS_KEY\n$AWS_REGION\n\n" | aws configure

# Install a JSON manipulation tool to extract data from AWS secret string
RUN yum -y install jq

# Install git and set access to the migrations repository
RUN yum -y install git
COPY $PRIVATE_KEY_FILE /root/.ssh/id_rsa

# Prevent SSH access prompt first time (add any other used host besides bitbucket and github)
RUN ssh-keyscan -H bitbucket.org >> ~/.ssh/known_hosts
RUN ssh-keyscan -H github.com >> ~/.ssh/known_hosts

# Get repository with migrations
ARG REPOSITORY_DIR=migrations
RUN git clone $REPOSITORY --branch $BRANCH --single-branch $REPOSITORY_DIR
RUN echo "export REPOSITORY_DIR=$REPOSITORY_DIR" >> /root/.bashrc
RUN echo "export MIGRATIONS_DIR=$MIGRATIONS_DIR" >> /root/.bashrc
RUN echo "export AWS_SECRET_ID=$AWS_SECRET_ID" >> /root/.bashrc

# Install the migration tool
RUN curl -L https://github.com/golang-migrate/migrate/releases/download/v$MIGRATE_VERSION/migrate.linux-amd64.tar.gz | tar xzv && \
    mv migrate.linux-amd64 /usr/local/bin/migrate

# Add migration script
COPY migrate.sh .
RUN chmod +x ./migrate.sh
