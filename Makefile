
MERE_MEMORY_WASM	= target/wasm32-unknown-unknown/release/mere_memory.wasm
STORAGE_DNA		= packs/dna/storage.dna
STORAGE_APP		= packs/app/Storage.happ

#
# Project
#
preview-crate:			test-debug
	cd mere_memory_types; cargo publish --dry-run
publish-crate:			test-debug
	cd mere_memory_types; CARGO_HOME=$(HOME)/.cargo cargo publish

mere-memory-zome:	$(MERE_MEMORY_WASM)

$(MERE_MEMORY_WASM):	Cargo.toml src/*.rs mere_memory_types/Cargo.toml mere_memory_types/src/*.rs default.nix
	@echo "Building zome: $@"; \
	RUST_BACKTRACE=1 CARGO_TARGET_DIR=target cargo build \
		--release --target wasm32-unknown-unknown
	@touch $@ # Cargo must have a cache somewhere because it doesn't update the file time

$(STORAGE_DNA):		$(MERE_MEMORY_WASM)
	hc dna pack packs/dna/
$(STORAGE_APP):		$(STORAGE_DNA)
	hc app pack packs/app/


#
# Testing
#
tests/package-lock.json:	tests/package.json
	touch $@
tests/node_modules:		tests/package-lock.json
	cd tests; npm install
	touch $@
test:			$(STORAGE_DNA) tests/node_modules
	cd tests; npx mocha integration/test_api.js
test-debug:		$(STORAGE_DNA) tests/node_modules
	cd tests; LOG_LEVEL=silly npx mocha integration/test_api.js


#
# Documentation
#
test-docs:
	cd mere_memory_types; cargo test --doc
build-docs:			test-docs
	cd mere_memory_types; cargo doc
