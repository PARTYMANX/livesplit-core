# This script takes care of building your crate and packaging it for release

set -ex

main() {
    local src=$(pwd) \
          stage=

    case $TRAVIS_OS_NAME in
        linux)
            stage=$(mktemp -d)
            ;;
        osx)
            stage=$(mktemp -d -t tmp)
            ;;
    esac

    test -f Cargo.lock || cargo generate-lockfile

    cross rustc -p livesplit-core-capi --target $TARGET --release

    (cd capi/bind_gen && cargo run)

    cp -r capi/bindings $stage/
    case $TRAVIS_OS_NAME in
        linux)
            cp target/$TARGET/release/liblivesplit_core_capi.so $stage/liblivesplit_core.so 2>/dev/null || :
            cp target/$TARGET/release/livesplit*.js* $stage/. 2>/dev/null || :
            cp target/$TARGET/release/deps/*.wasm $stage/livesplit.wasm 2>/dev/null || :
            ;;
        osx)
            cp target/$TARGET/release/liblivesplit_core_capi.dylib $stage/liblivesplit_core.dylib 2>/dev/null || :
            ;;
    esac
    cp target/$TARGET/release/liblivesplit_core_capi.a $stage/liblivesplit_core.a 2>/dev/null || :

    cd $stage
    tar czf $src/$CRATE_NAME-$TRAVIS_TAG-$TARGET.tar.gz *
    cd $src

    rm -rf $stage
}

main
