#!/bin/bash
set -e

echo "--- Starting Test ---"

echo "Installing dependencies..."
pip3 install -r requirements.txt > /dev/null

echo "Starting server..."
uvicorn main:app --host 0.0.0.0 --port 8000 &
SERVER_PID=$!

# Cleanup function
cleanup() {
  echo "Cleaning up server (PID: $SERVER_PID)..."
  kill $SERVER_PID >/dev/null 2>&1
}
trap cleanup EXIT

sleep 3 # Wait for the server to start

echo "--- Running tests ---"

# Function to test an endpoint
test_endpoint() {
  local url=$1
  local expected=$2
  local description=$3

  echo "➡️ Testing: $description ($url)"
  response=$(curl -s -o /tmp/response.json -w "%{http_code}" "$url")
  status_code=$(tail -n1 <<<"$response")
  content=$(cat /tmp/response.json)

  if [[ "$status_code" == "200" && "$content" == "$expected" ]]; then
    echo "✅ $description passed"
  else
    echo "❌ $description failed"
    echo "   Expected: $expected"
    echo "   Got:      $content (status $status_code)"
    exit 1
  fi
}

# Test 1 - Route principale
test_endpoint "http://localhost:8000" '{"Hello":"Docker"}' "Root endpoint"

# Test 2 - Si tu as un autre endpoint (ex: /health)
# if curl -s -f http://localhost:8000/health > /dev/null 2>&1; then
#   test_endpoint "http://localhost:8000/health" '{"status":"ok"}' "Health check"
# fi

# Test 3 - Exemple POST
# (à activer si tu as une route POST)
# response=$(curl -s -X POST http://localhost:8000/echo -H "Content-Type: application/json" -d '{"msg":"test"}')
# if [[ "$response" == '{"msg":"test"}' ]]; then
#   echo "✅ POST /echo passed"
# else
#   echo "❌ POST /echo failed (got $response)"
#   exit 1
# fi

echo "✅ All tests passed successfully."
