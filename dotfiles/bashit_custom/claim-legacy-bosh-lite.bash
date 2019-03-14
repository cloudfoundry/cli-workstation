function claim_legacy_bosh_lite() {
  if [ -n "$1" ] ; then
    STORY="$1"
    shift
  else
    STORY=nostory
  fi
  env_dir=$(
    set -e

    function msg {
      echo -e $1
    }

    function realpath {
      echo $(cd $(dirname "$1") && pwd -P)/$(basename "$1")
    }

    function claim_random_environment() {
      git pull --rebase --quiet --no-verify

      for f in $(ls -tr ./legacy-bosh-lites/unclaimed/*); do
        test -f "$f" || continue

        msg "Claiming $( basename $f )..."
        claim_specific_environment $(basename $f)
        return $?
      done

      msg "No unclaimed environment found in legacy-bosh-lites"
      return 1
    }

    function claim_specific_environment() {
      env=$1

      file=`find . -name $env`

      if [ "$file" == "" ]; then
        echo $env does not exist
        return 1
      fi

      set +e
      file_unclaimed=`echo $file | grep claim | grep -v unclaim`
      set -e

      if [ $file_unclaimed ]; then
        msg $env could not be claimed
        return 1
      fi

      newfile=`echo ${file} | sed -e 's/unclaimed/claimed/'`

      git mv $file $newfile

      git add "${newfile}"
    }

    function create_env_dir() {
      msg "Writing out .envrc..."
      env_file="$1"
      env_name="$(basename "${env_file}")"

      mkdir -p "${env_name}"

      green='\033[32m'
      nc='\033[0m'

      source "${env_file}"
      env_ssh_key_path="$HOME/workspace/cli-pools/${env_name}/bosh.pem"
      cat << EOF > "${env_name}/.envrc"
# NOTE: this file was auto-generated by 'claim_legacy_bosh_lite' alias

target_bosh "${env_name}"

echo -e "\n##################################\n"
echo -e "${green}Some example commands for BOSH + CF${nc}"

echo -e "${green}\n## Target CF API ##${nc}"
echo "cf api https://api.${BOSH_LITE_DOMAIN} --skip-ssl-validation"

echo -e "${green}\n## Unclaim this environment ##${nc}"
echo "unclaim_bosh_lite ${env_name}"

echo -e "${green}\n## Print this help text ##${nc}"
echo ". .envrc"

echo -e "\n##################################\n"
EOF
      git add "${env_name}"
    }

    function commit_and_push() {
      git commit --quiet --message "manually claim ${env} on ${HOSTNAME} [$STORY]" --no-verify
      msg "Pushing reservation to $( basename $PWD )..."
      git push --quiet
    }

    >&2 cd ~/workspace/cli-pools
    >&2 claim_random_environment $requested_input
    env_file="$(realpath $newfile)"

    >&2 create_env_dir "${env_file}"
    >&2 commit_and_push

    echo "$PWD/$(basename "${env_file}")"
  )

  if [ "$?" == 0 ]; then
    direnv allow "${env_dir}"
    echo "Changing directory to '${env_dir}'..."
    cd "${env_dir}"
  fi
}

export -f claim_legacy_bosh_lite
