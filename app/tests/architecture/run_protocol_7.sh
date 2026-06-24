#!/usr/bin/env bash

# ==============================
# Protocol 7 - Automated Runner
# ==============================

PACKAGE="com.ittybittybites.liquidmemory"
RUNS=10
COOLDOWN_SEC=20

OUTPUT_DIR="protocol7_logs"
mkdir -p "$OUTPUT_DIR"

echo "=== Protocol 7 Automation Starting ==="
echo "Package: $PACKAGE"
echo "Runs: $RUNS"
echo "Cooldown: ${COOLDOWN_SEC}s"
echo "Output: $OUTPUT_DIR"
echo "======================================"

for i in $(seq 1 $RUNS)
do
    RUN_ID=$(printf "%02d" $i)
    LOG_FILE="$OUTPUT_DIR/protocol7_run_${RUN_ID}.txt"

    echo ""
    echo ">>> RUN $RUN_ID STARTING"

    # 1. Hard reset app state
    adb shell am force-stop $PACKAGE

    # 2. Reset GPU/Frame metrics
    adb shell dumpsys gfxinfo reset

    # 3. Thermal / scheduler stabilization window
    echo "Cooling down for ${COOLDOWN_SEC}s..."
    sleep $COOLDOWN_SEC

    # 4. Start log capture (background)
    adb logcat -c
    adb logcat > "$LOG_FILE" &
    LOGCAT_PID=$!

    # 5. Launch app
    # Using monkey to blindly launch the main intent
    adb shell monkey -p $PACKAGE 1 > /dev/null 2>&1

    echo "App launched. Waiting for run completion..."

    # 6. Wait for user-defined completion marker
    while true
    do
        if grep -q "PROTOCOL_7_COMPLETE" "$LOG_FILE" 2>/dev/null; then
            break
        fi
        sleep 1
    done

    # 7. Stop log capture
    kill $LOGCAT_PID

    echo ">>> RUN $RUN_ID COMPLETE"
    echo "Saved: $LOG_FILE"

    # 8. Post-run cooldown (prevents thermal carryover)
    echo "Post-run cooldown..."
    sleep 5

done

echo ""
echo "=== Protocol 7 COMPLETE ==="
echo "All logs stored in: $OUTPUT_DIR"
