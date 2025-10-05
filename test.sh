#!/bin/bash
set -e

echo "--- Starting Test ---"
echo "Installing dependencies..."
pip3 install -r requirements.txt > /dev/null

echo "Starting server..."
uvicorn main:app --host 0.0.0.0 --port 8000 &
SERVER_PID=$!

# Cleanup function to always stop the server
cleanup() {
  echo "Cleaning up server (PID: $SERVER_PID)..."
  kill $SERVER_PID
}
# Register the cleanup function to run on script exit
trap cleanup EXIT

sleep 3 # Wait for the server to start

echo "Running tests..."
RESPONSE=$(curl -s http://localhost:8000)
EXPECTED='{"Hello":"World"}'

if [ "$RESPONSE" == "$EXPECTED" ]; then
  echo "✅ Test Passed: Response matches expected output."
  exit 0
else
  echo "❌ Test Failed: Unexpected response."
  echo "   Expected: $EXPECTED"
  echo "   Got:      $RESPONSE"
  exit 1
fi
