VERSION:=9.5
TAG:=base
APP:=postgres
REPO:=822924222578.dkr.ecr.us-east-1.amazonaws.com/$(APP)
URL:=$(REPO):$(TAG)

default:
	@echo "Usage make [image | stopdb | rundb | runpsql | commit | push | check]"

login:
	`aws ecr get-login --region us-east-1`

image:login
	echo "Building $(APP)"
	docker build -t $(URL) $(VERSION)/.
	make push

stopdb:
	-docker rm -f $(APP)

rundb:stopdb
	docker run -d --name $(APP) -e POSTGRES_PASSWORD=password $(URL)

runpsql:
	docker run -it --rm --link $(APP):postgres postgres psql -h postgres -U postgres

commit:login
	docker commit $(APP) $(URL)
	make push

push:
	docker push $(URL)

check:
	docker ps -f name=$(APP)
	docker images $(URL)

clean:
	-docker rmi `docker images -a | grep "^<none>" | awk '{print $3}'`
	-docker rmi `docker images -a | grep "$(REPO)" | awk '{print $3}'`
	
	