#!/bin/bash

# Run all property-based tests for VOS_PingPong
# This script runs all standalone test files

echo "=========================================="
echo "Running All Property-Based Tests"
echo "=========================================="
echo ""

FAILED_TESTS=()
PASSED_TESTS=()

# Function to run a test and track results
run_test() {
    local test_name="$1"
    local test_file="$2"
    
    echo "Running: $test_name"
    echo "------------------------------------------"
    
    if swift "$test_file"; then
        PASSED_TESTS+=("$test_name")
        echo ""
    else
        FAILED_TESTS+=("$test_name")
        echo ""
    fi
}

# Run all standalone tests
run_test "Audio Tests (Property 16)" "VOS_PingPongTests/RunAudioTests.swift"
run_test "Collision Physics Tests (Properties 6, 7, 9)" "VOS_PingPongTests/RunCollisionPhysicsTests.swift"
run_test "Boundary Tests (Property 17)" "VOS_PingPongTests/BoundaryTests.swift"
run_test "Ball Physics Tests (Properties 8, 20)" "VOS_PingPongTests/BallPhysicsTests.swift"
run_test "Entity Logic Tests (Properties 1, 2, 3)" "VOS_PingPongTests/VerifyEntityLogic.swift"
run_test "Ground Detection Tests (Property 13)" "VOS_PingPongTests/VerifyGroundDetection.swift"
run_test "Integration Tests (Complete Game Flow)" "VOS_PingPongTests/RunIntegrationTests.swift"

# Print summary
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo ""
echo "Passed: ${#PASSED_TESTS[@]}"
for test in "${PASSED_TESTS[@]}"; do
    echo "  ✅ $test"
done
echo ""

if [ ${#FAILED_TESTS[@]} -gt 0 ]; then
    echo "Failed: ${#FAILED_TESTS[@]}"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  ❌ $test"
    done
    echo ""
    echo "❌ Some tests failed!"
    exit 1
else
    echo "✅ All tests passed!"
    exit 0
fi
