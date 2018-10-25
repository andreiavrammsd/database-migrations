# Migration tool version (https://github.com/golang-migrate/migrate)
MIGRATE_VERSION := 4.0.2

NAME := dbmigrate
PRIVATE_KEY_FILE := "./private_key"

build:
	cp -f ${PRIVATE_KEY_PATH} ${PRIVATE_KEY_FILE}
	docker build \
		--build-arg AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \
		--build-arg AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
		--build-arg AWS_REGION=${AWS_REGION} \
		--build-arg AWS_SECRET_ID=${AWS_SECRET_ID} \
		--build-arg REPOSITORY=${REPOSITORY} \
		--build-arg BRANCH=${BRANCH} \
		--build-arg MIGRATIONS_DIR=${MIGRATIONS_DIR} \
		--build-arg PRIVATE_KEY_FILE=${PRIVATE_KEY_FILE} \
		--build-arg MIGRATE_VERSION=${MIGRATE_VERSION} \
 		-t ${NAME} .
	rm -f ${PRIVATE_KEY_FILE}

start:
	docker run --rm -dt --name ${NAME} ${NAME}

stop:
	docker stop ${NAME} || true

clean:
	docker rm -f ${NAME} || true
	docker rmi -f ${NAME} || true

up:
	docker exec ${NAME} sh -c ". ~/.bashrc && ./migrate.sh up"

down:
	docker exec ${NAME} sh -c ". ~/.bashrc && ./migrate.sh down ${steps}"
