value "DOCKER_HUB_NAME" {
  literal = "dmcsorley"
}

value "DOCKER_HUB_EMAIL" {
  env = "GOBLIN_DOCKER_HUB_EMAIL"
}

value "DOCKER_HUB_PASSWORD" {
  env = "GOBLIN_DOCKER_HUB_PASSWORD"
}

/*
 Builds occur in an isolated container, launched by the parent goblin process.
 The build containers have a docker volume mounted at /tmp/workdir by default.
 */
build "goblin" {
  # clone the repository from `url` into the working directory
  step git-clone {
    url = "https://github.com/dmcsorley/goblin"
  }

  # pull the `image` specified
  step docker-pull {
    image = "golang"
  }

  # run the specified docker `image` in a container
  step docker-run {
    image = "golang"
    /*
     mount the working volume at this location in the run container
     this will also be the working directory
     */
    dir = "/go/src/github.com/dmcsorley/goblin"
    # the command to execute in the container
    cmd = "go get -v -d && go install -v && cp /go/bin/goblin ./bin/"

    /*
     this whole step is equivalent to:
     `docker run -d \
       -w /go/src/github.com/dmcsorley/goblin \
       -v $VOLUME:/go/src/github.com/dmcsorley/goblin \
       golang bash -c \
       "go get -v -d && go install -v && cp /go/bin/goblin ./bin/"`
     */
  }

  # pulling before a run or build is optional, but recommended
  # if you always want the newest version of the image
  step docker-pull {
    image = "buildpack-deps:xenial-scm"
  }

  # docker build in the working directory using the default Dockerfile
  step docker-build {
    image = "dmcsorley/goblin"
  }

  # At the end of the build, everything is unwound; images, containers, and volumes are removed
}

# A simpler build, with a single-step build from scratch
build captainhook {
  step git-clone {
    url = "https://github.com/dmcsorley/captainhook"
  }
  step docker-pull {
    image = "golang:1.4.2-onbuild"
  }
  step docker-build {
    image = "dmcsorley/captainhook"
  }
}
