using RootfsUtils: parse_build_args, upload_gha, test_sandbox
using RootfsUtils: debootstrap
using RootfsUtils: root_chroot

args         = parse_build_args(ARGS, @__FILE__)
arch         = args.arch
archive      = args.archive
image        = args.image

packages = [
    "bash",
    "build-essential",
    "coreutils",
    "ca-certificates",
    "curl",
    "gnupg",
    "gfortran",
    "git",
    "locales",
    "localepurge",
]

artifact_hash, tarball_path, = debootstrap(arch, image; archive, packages) do rootfs, chroot_ENV
    my_chroot(args...) = root_chroot(rootfs, "bash", "-eu", "-o", "pipefail", "-c", args...; ENV=chroot_ENV)

    cmd = """
    # install openmodelica
    set -Eeu -o pipefail
    curl -fsSL http://build.openmodelica.org/apt/openmodelica.asc | gpg --dearmor -o /usr/share/keyrings/openmodelica-keyring.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/openmodelica-keyring.gpg] \
        https://build.openmodelica.org/apt \
        bullseye \
        stable" | tee /etc/apt/sources.list.d/openmodelica.list

    apt update
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends omc
    rm -rf /var/lib/apt/lists/*
    """
    my_chroot(cmd)
end

@info artifact_hash
@info tarball_path
test_sandbox(artifact_hash)
