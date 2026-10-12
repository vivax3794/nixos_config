set -euo pipefail

state_dir="${XDG_CACHE_HOME:-$HOME/.cache}/immich-offload"
auth_file="${XDG_CONFIG_HOME:-$HOME/.config}/immich/auth.yml"
container=immich-offload
pi="root@$PI_ADDRESS"
pi_server=documents-immich-server-1

processing_queues=(
  thumbnailGeneration metadataExtraction videoConversion faceDetection facialRecognition
  smartSearch duplicateDetection ocr storageTemplateMigration
)

offload_concurrency='
  .job.thumbnailGeneration.concurrency = 24
  | .job.metadataExtraction.concurrency = 48
  | .job.sidecar.concurrency = 16
  | .job.videoConversion.concurrency = 4
  | .job.faceDetection.concurrency = 8
  | .job.smartSearch.concurrency = 8
  | .job.ocr.concurrency = 8'

default_concurrency='
  .job.thumbnailGeneration.concurrency = 3
  | .job.metadataExtraction.concurrency = 5
  | .job.sidecar.concurrency = 5
  | .job.videoConversion.concurrency = 1
  | .job.faceDetection.concurrency = 2
  | .job.smartSearch.concurrency = 2
  | .job.ocr.concurrency = 1'

url=$(sed -n 's/^url: *//p' "$auth_file")
key=$(sed -n 's/^key: *//p' "$auth_file")

api() {
  local method=$1 path=$2
  shift 2
  curl -fsS -X "$method" -H "x-api-key: $key" -H 'Content-Type: application/json' "$url$path" "$@"
}

all_queues() {
  api GET /jobs | jq -r 'keys[]'
}

queue_command() {
  local command=$1 queue
  shift
  for queue in "$@"; do
    api PUT "/jobs/$queue" -d "{\"command\":\"$command\",\"force\":false}" >/dev/null || true
  done
}

set_concurrency() {
  api GET /system-config | jq "$1" | api PUT /system-config --data @- >/dev/null
}

set_pi_workers() {
  ssh "$pi" "cd '$PI_STACK_DIR' && IMMICH_PI_WORKERS=$1 docker compose up -d immich-server"
}

wait_for() {
  local description=$1
  shift
  echo "waiting for $description..."
  for _ in $(seq 1 150); do
    if "$@" 2>&1 | grep -q 'Microservices is running'; then
      return
    fi
    sleep 2
  done
  echo "timed out waiting for $description" >&2
  exit 1
}

pause_until_exit() {
  mapfile -t paused_queues < <(all_queues)
  queue_command pause "${paused_queues[@]}"
  trap 'queue_command resume "${paused_queues[@]}"; echo "queues resumed"' EXIT
  echo "queues paused"
}

cmd_on() {
  pause_until_exit

  local image
  image=$(ssh "$pi" "docker image inspect \$(docker inspect $pi_server --format '{{.Image}}') --format '{{index .RepoDigests 0}}'")
  echo "worker image: $image"

  mkdir -p "$state_dir"
  (
    umask 077
    {
      echo "DB_HOSTNAME=$PI_ADDRESS"
      echo "DB_USERNAME=postgres"
      echo "DB_DATABASE_NAME=immich"
      ssh "$pi" "sed -n 's/^IMMICH_DB_PASSWORD=/DB_PASSWORD=/p' '$PI_STACK_DIR/.env'"
      echo "REDIS_HOSTNAME=$PI_ADDRESS"
      echo "IMMICH_WORKERS_EXCLUDE=api"
    } >"$state_dir/worker.env"
  )

  ls "$LIBRARY_MOUNT" >/dev/null
  set_pi_workers api

  podman run -d --replace --name "$container" --network host \
    --env-file "$state_dir/worker.env" \
    -v "$LIBRARY_MOUNT:/data" -v /etc/localtime:/etc/localtime:ro \
    "$image" >/dev/null
  wait_for "desktop worker startup" podman logs "$container"

  set_concurrency "$offload_concurrency"
  echo "offload on"
}

cmd_off() {
  pause_until_exit

  podman rm -f "$container" >/dev/null 2>&1 || true
  set_concurrency "$default_concurrency"

  local since
  since=$(ssh "$pi" date -u +%Y-%m-%dT%H:%M:%SZ)
  set_pi_workers api,microservices
  wait_for "Pi worker startup" ssh "$pi" docker logs --since "$since" "$pi_server"
  echo "offload off"
}

cmd_missing() {
  queue_command start "${processing_queues[@]}"
  echo "queued missing jobs for: ${processing_queues[*]}"
}

cmd_status() {
  if podman container exists "$container"; then
    echo "worker: $(podman ps --filter "name=^$container\$" --format '{{.Status}}')"
  else
    echo "worker: not running"
  fi
  api GET /jobs | jq -r '
    to_entries[]
    | select(.value.jobCounts.waiting + .value.jobCounts.active > 0 or .value.queueStatus.isPaused)
    | "\(.key)\t\(.value.jobCounts.waiting) waiting\t\(.value.jobCounts.active) active\(if .value.queueStatus.isPaused then "\tpaused" else "" end)"' |
    column -t -s $'\t'
}

case "${1:-status}" in
on) cmd_on ;;
off) cmd_off ;;
missing) cmd_missing ;;
status) cmd_status ;;
*)
  echo "usage: immich-offload [on|off|missing|status]" >&2
  exit 1
  ;;
esac
