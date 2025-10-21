#!/bin/bash
set -e

# --- CONFIG ---
PROJECT_DIR=$(dirname $(dirname $(realpath $0)))
BUILD_DIR="$PROJECT_DIR/build"
DEPLOY_DIR="$PROJECT_DIR/deployments"
ARTIFACT_PREFIX="my-app"
MAX_BUILDS=5
LOG_FILE="$PROJECT_DIR/scripts/pipeline.log"
ENV_FILE="$PROJECT_DIR/app-data/config.env"

# --- LOAD ENVIRONMENT ---
if [ -f "$ENV_FILE" ]; then
    echo "[INFO] Loading environment variables from $ENV_FILE"
    export $(grep -v '^#' "$ENV_FILE" | xargs)
else
    echo "[WARN] No config.env file found at $ENV_FILE"
fi

# --- FUNCTIONS ---
log_info() {
    echo "[INFO] $1" | tee -a "$LOG_FILE"
}

log_error() {
    echo "[ERROR] $1" | tee -a "$LOG_FILE"
}

notify_slack() {
    local message="$1"
    if [ -n "$SLACK_WEBHOOK_URL" ]; then
        curl -s -X POST -H 'Content-type: application/json' \
             --data "{\"text\":\"$message\"}" "$SLACK_WEBHOOK_URL" > /dev/null
    fi
}

cleanup_old_builds() {
    log_info "Cleaning up old builds..."
    builds=($(ls -1tr $BUILD_DIR/${ARTIFACT_PREFIX}-*.tar.gz 2>/dev/null))
    num_builds=${#builds[@]}
    if (( num_builds > MAX_BUILDS )); then
        for ((i=0; i<num_builds-MAX_BUILDS; i++)); do
            rm -f "${builds[i]}"
            rm -f "${builds[i]}.sha256" 2>/dev/null
            log_info "Deleted old build: ${builds[i]}"
        done
    fi
}

# --- PIPELINE ---
log_info "--- CI/CD Pipeline Started ---"

# 1️⃣ Linting
log_info "Stage: Linting"
if ! bash -n "$PROJECT_DIR/tools/my-app/app.sh"; then
    notify_slack "Lint failed"
    log_error "Lint failed"
    exit 1
fi
log_info "Linting passed"

# 2️⃣ Build
log_info "Stage: Building"
mkdir -p "$BUILD_DIR"
BUILD_ID=$(date +%s)
ARTIFACT_NAME="${ARTIFACT_PREFIX}-${BUILD_ID}.tar.gz"
tar -czf "$BUILD_DIR/$ARTIFACT_NAME" -C "$PROJECT_DIR/tools" my-app
log_info "Build artifact created: $BUILD_DIR/$ARTIFACT_NAME"

# Cleanup old builds
cleanup_old_builds

# 3️⃣ Test
log_info "Stage: Testing"

TEST_SCRIPT="$PROJECT_DIR/tools/test.sh"

if [ ! -f "$TEST_SCRIPT" ]; then
    notify_slack "Test script not found: $TEST_SCRIPT"
    log_error "Test script not found: $TEST_SCRIPT"
    exit 1
fi

chmod +x "$TEST_SCRIPT"

log_info "Executing test script..."
if ! (cd "$PROJECT_DIR/tools/my-app/src" && "$TEST_SCRIPT"); then
    notify_slack "❌ Tests failed for $ARTIFACT_NAME"
    log_error "Tests failed. Check logs for details."
    exit 1
else
    log_info "✅ Tests passed successfully."
fi

# 4️⃣ Docker Build & Push
if command -v docker &> /dev/null; then
    log_info "Stage: Docker Build"
    docker build -t my-app:$BUILD_ID "$PROJECT_DIR" -f "$PROJECT_DIR/docker/web/Dockerfile"

    # Tag Docker image with repository name
    if [ -n "$DOCKER_REPO" ]; then
        docker tag my-app:$BUILD_ID $DOCKER_REPO:$BUILD_ID
        docker tag my-app:$BUILD_ID $DOCKER_REPO:latest
        log_info "Tagged Docker image as $DOCKER_REPO:$BUILD_ID and latest"

        # Login & Push
        if [ -n "$DOCKER_USERNAME" ] && [ -n "$DOCKER_PASSWORD" ]; then
            echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
            log_info "Pushing Docker image to Docker Hub..."
            docker push $DOCKER_REPO:$BUILD_ID
            docker push $DOCKER_REPO:latest
            docker logout
            log_info "Docker image pushed successfully."
        else
            log_error "Docker credentials not found in environment. Skipping push."
        fi
    else
        log_error "DOCKER_REPO not defined. Skipping Docker push."
    fi
else
    log_error "Docker command not found. Skipping Docker stages."
fi

# 5️⃣ Deploy
log_info "Stage: Deploying"
mkdir -p "$DEPLOY_DIR"
cp "$BUILD_DIR/$ARTIFACT_NAME" "$DEPLOY_DIR/"
ln -sf "$DEPLOY_DIR/$ARTIFACT_NAME" "$DEPLOY_DIR/latest.tar.gz"
log_info "Artifact deployed to $DEPLOY_DIR/latest.tar.gz"

# 6️⃣ Monitoring (system + app)
log_info "Stage: Monitoring"
MONITOR_SCRIPT="$PROJECT_DIR/scripts/monitor.py"

if [ -f "$MONITOR_SCRIPT" ]; then
    log_info "Running monitor.py (single check)"
    python3 "$MONITOR_SCRIPT"
else
    log_info "No monitor.py found, skipping monitoring."
fi

log_info "Sending Slack notification..."
notify_slack "CI/CD Pipeline finished successfully: $ARTIFACT_NAME"

log_info "--- CI/CD Pipeline Finished Successfully ---"

# 7️⃣ Remote Deployment
# if [ "$ENV" = "preprod" ] || [ "$ENV" = "prod" ]; then
#     log_info "Stage: Remote Deployment ($ENV)"

#     REMOTE_HOST="user@mon-serveur"
#     REMOTE_PATH="/var/www/my-app"

#     log_info "Deploying $ARTIFACT_NAME to $REMOTE_HOST:$REMOTE_PATH"
#     scp "$DEPLOY_DIR/$ARTIFACT_NAME" "$REMOTE_HOST:$REMOTE_PATH/"
    
#     ssh "$REMOTE_HOST" <<EOF
#         cd "$REMOTE_PATH"
#         tar -xzf "$ARTIFACT_NAME"
#         ln -sf "$ARTIFACT_NAME" latest.tar.gz
#         echo "✅ Deployed $ARTIFACT_NAME on $ENV environment"
# EOF

#     notify_slack "🚀 Deployed $ARTIFACT_NAME on $ENV environment"
# fi

