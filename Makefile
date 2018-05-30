.PHONY: update-eu-structural-funds ci-build ci-run ci-test ci-remove ci-push-tag ci-push-latest ci-login

NAME   := os-data-importers
ORG    := openspending
REPO   := ${ORG}/${NAME}
TAG    := $(shell git log -1 --pretty=format:"%h")
IMG    := ${REPO}:${TAG}
LATEST := ${REPO}:latest

ci-build:
	docker pull ${LATEST}
	docker build --cache-from ${LATEST} -t ${IMG} -t ${LATEST} .

ci-run:
	docker run ${RUN_ARGS} --name ${NAME} -d ${LATEST}

ci-test:
	docker ps | grep latest
	docker exec ${NAME} npm test

ci-remove:
	docker rm -f ${NAME}

ci-push: ci-login
	docker push ${IMG}
	docker push ${LATEST}

ci-push-tag: ci-login
	docker build -t ${REPO}:${TAG} .
	docker push ${REPO}:${TAG}

ci-login:
	docker login -u ${DOCKER_HUB_USERNAME} -p ${DOCKER_HUB_PASSWORD}

update-eu-structural-funds:
	git subtree pull \
		--prefix eu-structural-funds \
		https://github.com/os-data/eu-structural-funds.git \
		master \
		--squash -m "Merge eu-structural-funds"

