PREFIX=/usr/local
BIN_DIR=$(PREFIX)/bin
SERVICE_DIR=/usr/lib/systemd/system
TARGET=
PROFILE=native

target/release/doqxy: src/main.rs Cargo.toml Cargo.lock
	cargo build --release

target/native/doqxy: src/main.rs Cargo.toml Cargo.lock
	RUSTFLAGS="-C target-cpu=native" cargo build --profile native

target/doqxy.service: doqxy.service.in
	sed "s|@BIN_DIR@|$(BIN_DIR)|g" doqxy.service.in > target/doqxy.service

.PHONY: build install clean uninstall

build-bin: target/$(PROFILE)/doqxy
build-service: target/doqxy.service
build: build-bin build-service

install-bin: build
	install -m 755 target/$(PROFILE)/doqxy $(TARGET)$(BIN_DIR)/doqxy
install-service: build-service
	install -m 644 target/doqxy.service $(TARGET)$(SERVICE_DIR)/doqxy.service
install: install-bin install-service

clean:
	rm -f target/release/doqxy target/native/doqxy target/doqxy.service

fmt:
	cargo fmt --all

lint:
	cargo fmt --all -- --check
	cargo clippy --all -- -D warnings

check: lint
	cargo check --all

uninstall:
	rm $(TARGET)$(BIN_DIR)/doqxy
	rm $(TARGET)$(SERVICE_DIR)/doqxy.service