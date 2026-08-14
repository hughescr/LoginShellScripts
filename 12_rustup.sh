if [ -n "${HOMEBREW_PREFIX}" ]; then
    # rustup proxies (keg-only) must beat the rust formula's stable cargo
    # so toolchain pins like Bun's rust-toolchain.toml work
    export PATH="${HOMEBREW_PREFIX}/opt/rustup/bin:$PATH"
fi
