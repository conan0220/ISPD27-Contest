#!/usr/bin/env bash
set -euo pipefail

container_name=ispd2027
image=udxs/ispd27:v1
repo_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
container_dir=/workspace/ISPD27-Contest

if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker is not available in PATH." >&2
    exit 1
fi
if ! docker info >/dev/null 2>&1; then
    echo "Error: cannot connect to Docker. Start Docker and try again." >&2
    exit 1
fi

# Load the same tool environment for both new and existing containers.
# The image's original entrypoint points OPENROAD_EXE at a missing build file.
container_shell='
set -e
source /opt/miniconda3/etc/profile.d/conda.sh
conda activate base
export PATH="/opt/oss-cad-suite/bin:/install/OpenROAD/bin:$PATH"
export OPENROAD_EXE=/install/OpenROAD/bin/openroad
export YOSYS_EXE=/opt/oss-cad-suite/bin/yosys
exec /bin/bash -i
'

if status=$(docker container inspect --format '{{.State.Status}}' "$container_name" 2>/dev/null); then
    case "$status" in
        running)
            ;;
        created|exited)
            docker start "$container_name" >/dev/null
            ;;
        *)
            echo "Error: container $container_name is $status. Cannot enter it." >&2
            exit 1
            ;;
    esac
    exec docker exec -it --workdir "$container_dir" \
        "$container_name" /bin/bash -c "$container_shell"
else
    exec docker run --platform linux/amd64 -it \
        --name "$container_name" \
        --volume "$repo_dir:$container_dir" \
        --workdir "$container_dir" \
        --entrypoint /bin/bash \
        "$image" -c "$container_shell"
fi
