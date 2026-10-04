TEMPLATE = subdirs
SUBDIRS = \
    moonlight-common-c \
    qmdnsengine \
    app

# Build the dependencies in parallel before the final app
app.depends = qmdnsengine moonlight-common-c
win32:!winrt {
    SUBDIRS += AntiHooking
    app.depends += AntiHooking
}

!disable-h264bitstream {
    SUBDIRS += h264bitstream
    app.depends += h264bitstream
}

# PyroWave codec library (see pyrowave/VENDOR.txt). Must match the condition
# in app/app.pro. Linux and macOS decode with Vulkan and present through
# libplacebo. Unlike the other two, macOS is not limited to x86_64.
win32:!winrt:contains(QT_ARCH, x86_64):!disable-pyrowave {
    SUBDIRS += pyrowave
    app.depends += pyrowave
}
linux:contains(QT_ARCH, x86_64):!disable-pyrowave:!disable-libplacebo:packagesExist(libplacebo) {
    SUBDIRS += pyrowave
    app.depends += pyrowave
}
# macOS has no pkg-config entry for the prebuilt libplacebo, so mirror the
# condition app/app.pro uses instead of packagesExist().
macx:!disable-prebuilts:!disable-libplacebo:!disable-pyrowave {
    SUBDIRS += pyrowave
    app.depends += pyrowave
}

# Support debug and release builds from command line for CI
CONFIG += debug_and_release

# Deterministic VRR tests are deliberately opt-in. Package and normal
# application builds keep their existing target set unless CONFIG+=tests is
# supplied to qmake.
contains(CONFIG, tests) {
    SUBDIRS += tests
}

# Run our compile tests
load(configure)
qtCompileTest(SL)
qtCompileTest(EGL)
