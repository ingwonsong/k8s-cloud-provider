# Copyright 2018 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

all: gen build test

.PHONY: gen
gen:
	go run pkg/cloud/gen/main.go > pkg/cloud/gen.go
	go run pkg/cloud/gen/main.go -mode test > pkg/cloud/gen_test.go
	gofmt -w pkg/cloud/gen.go
	gofmt -w pkg/cloud/gen_test.go

.PHONY: build
build: gen
	go build ./...
	mkdir -p bin

# COVTMP is the temp file used to check coverage.
COVTMP := $(shell mktemp)

.PHONY: test
test: gen
	# Test only the library. e2e must be run in a special environment,
	# so is skipped.
	go test ./pkg/...
	# We cannot use golint currently due to errors in the GCP API naming.
	# golint ./...
	go vet ./...
	# Coverage
	go test -cover ./pkg/... > $(COVTMP)
	go run ./tools/checkcov.go -configFile ./tools/checkcov.yaml -covFile $(COVTMP)
	rm -f $(COVTMP)

.PHONY: clean
clean:
	rm -rf ./bin
