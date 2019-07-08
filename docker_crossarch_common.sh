#!/usr/bin/env bash

__crossarch_common_version="1.1.0"

__crossarch_archs=(${CROSSARCH_ARCHS:="amd64 armhf aarch64"})
__crossarch_alpine_branch=(${CROSSARCH_ALPINE_BRANCH:="v3.7 v3.9 v3.10"})
__crossarch_use_multiarch_alpine=${CROSSARCH_USE_MULTIARCH_ALPINE:="true"}

__crossarch_build_is_semver=${CROSSARCH_BUILD_IS_SEMVER:="true"}
__crossarch_build_squash=${CROSSARCH_BUILD_SQUASH:="false"}

__die () {
  printf '  ❌ \033[1;31mERROR: %s\033[0m\n' "$@" >&2  # bold red
  exit 1
}

__info () {
  printf '  \033[1;36m> %s\033[0m\n' "$@" >&2  # bold cyan
}

__warn () {
  printf '  ⚠ \033[1;33mWARNING: %s\033[0m\n' "$@" >&2  # bold yellow
}

__crossarch_welcome () {
  local welcome
  welcome=$(cat <<EOF
  ____                                  _     
 / ___|_ __ ___  ___ ___  __ _ _ __ ___| |__  
| |   | '__/ _ \/ __/ __|/ _\` | '__/ __| '_ \ 
| |___| | | (_) \__ \__ \ (_| | | | (__| | | |
 \____|_|  \___/|___/___/\__,_|_|  \___|_| |_|
 
Version ${__crossarch_common_version}
EOF
)

  printf '\033[1;35m%s\033[0m\n\n' "${welcome}" >&2
}

__crossarch_common_parse_semver () {
  local re='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
  # MAJOR
  # shellcheck disable=SC2001
  eval "${2}"="$(echo "${1}" | sed -e "s#${re}#\1#")"
  # MINOR
  # shellcheck disable=SC2001
  eval "${3}"="$(echo "${1}" | sed -e "s#${re}#\2#")"
  # MINOR
  # shellcheck disable=SC2001
  eval "${4}"="$(echo "${1}" | sed -e "s#${re}#\3#")"
  # SPECIAL
  # shellcheck disable=SC2001
  eval "${5}"="$(echo "${1}" | sed -e "s#${re}#\4#")"
}

crossarch_common_cache () {
  local build_name="${1}"
  docker pull --all-tags  "gaetancambier/${build_name}"
}

crossarch_common_build () {
  local build_name="${1}"
  local dockerfile="${2}"
  local entrypoint="${3}"

  __crossarch_welcome

  
  __info "Building Crossarch images for ${__crossarch_archs[*]} (on top of Alpine ${__crossarch_alpine_branch[*]})"
  
  __info "Registering QEMU..."
  docker run --rm --privileged multiarch/qemu-user-static:register --reset
  
  for arch in "${__crossarch_archs[@]}"; do
    for branch in "${__crossarch_alpine_branch[@]}"; do
      local tmp_dir
      tmp_dir=$(mktemp -d -p /tmp crossarch.XXXXXX)

      cp "${dockerfile}" "${tmp_dir}/Dockerfile"
      if [[ -f "${entrypoint}" ]]; then
        cp "${entrypoint}" "${tmp_dir}/entrypoint.sh"
      fi

      local image_to_use
      image_to_use="gaetancambier/alpine:${arch}-${branch}"
    
      if [ "${__crossarch_use_multiarch_alpine}" = "true" ]; then
        image_to_use="multiarch/alpine"

        local multiarch_alpine_arch
        if [ "${arch}" = "amd64" ]; then
          multiarch_alpine_arch="x86_64"
        elif [ "${arch}" = "armhf" ]; then
          multiarch_alpine_arch="armhf"
        fi
      
        image_to_use="${image_to_use}:${multiarch_alpine_arch}-${branch}"
      fi
      
      local prepend
      prepend=$(cat <<EOF
FROM ${image_to_use}
ENV CROSSARCH_ARCH=${arch}
EOF
)
      cp "${tmp_dir}/Dockerfile" "${tmp_dir}/Dockerfile.tmp"
      echo -e "${prepend}\n$(cat "${tmp_dir}/Dockerfile.tmp")" > "${tmp_dir}/Dockerfile"
      local build_flags
      build_flags=( )
    
      if [ "${__crossarch_build_squash}" = "true" ]; then
        build_flags+=(--squash)
      fi
    
    __info "Building ${arch} image..."
    docker build "${build_flags[@]}" --cache-from "gaetancambier/${build_name}:${arch}-latest" -t "build:${arch}" "${tmp_dir}"
    rm -rf "${tmp_dir}"
    done
  done
}

crossarch_common_deploy () {
  local docker_username="${1}"
  local docker_password="${2}"
  local build_name="${3}"
  local build_version="${4}"
  
  local build_version_major=0
  local build_version_minor=0
  local build_version_patch=0
  # shellcheck disable=SC2034
  local build_version_special=""
  
  __info "Deploying ${build_name} (${build_version})..."
    
  if [ "${__crossarch_build_is_semver}" = "true" ]; then
    __crossarch_common_parse_semver "${build_version}" build_version_major build_version_minor build_version_patch build_version_special
    
    __info "Version major: ${build_version_major}, minor: ${build_version_minor}, patch: ${build_version_patch}"
  fi

  
  __info "Pushing images to Docker Hub..."
  docker login -u "${docker_username}" -p "${docker_password}"
  for arch in "${__crossarch_archs[@]}"; do
    if [ "${__crossarch_build_is_semver}" = "true" ]; then
      docker tag "build:${arch}" "gaetancambier/${build_name}:${arch}-${build_version_major}"
      docker tag "build:${arch}" "gaetancambier/${build_name}:${arch}-${build_version_major}.${build_version_minor}"
      docker tag "build:${arch}" "gaetancambier/${build_name}:${arch}-${build_version_major}.${build_version_minor}.${build_version_patch}"
      docker tag "build:${arch}" "gaetancambier/${build_name}:${arch}-latest"
      docker push "gaetancambier/${build_name}:${arch}-${build_version_major}"
      docker push "gaetancambier/${build_name}:${arch}-${build_version_major}.${build_version_minor}"
      docker push "gaetancambier/${build_name}:${arch}-${build_version_major}.${build_version_minor}.${build_version_patch}"
      docker push "gaetancambier/${build_name}:${arch}-latest"
    else
      docker tag "build:${arch}" "gaetancambier/${build_name}:${arch}-${build_version}"
      docker tag "build:${arch}" "gaetancambier/${build_name}:${arch}-latest"
      docker push "gaetancambier/${build_name}:${arch}-${build_version}"
      docker push "gaetancambier/${build_name}:${arch}-latest"
    fi
  done
}



crossarch_common_entry () {
  local build_name="${1}"
  local docker_username="${2}"
  local docker_password="${3}"

  crossarch_common_cache "${build_name}"
  if [[ -f "./${build_name}/entrypoint.sh" ]]; then
    crossarch_common_build "${build_name}" "./${build_name}/Dockerfile" "./${build_name}/entrypoint.sh"
  else
    crossarch_common_build "${build_name}" "./${build_name}/Dockerfile"
  fi
  source "./${build_name}/get_version.sh"
  local build_version
  build_version=$(crossarch_build_get_version)
  crossarch_common_deploy "${docker_username}" "${docker_password}" "${build_name}" "${build_version}"
}


