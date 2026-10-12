#!/bin/bash
cd /home/claude/medseg-rai
while ! grep -q "queue3\] all done" /home/claude/queue.log; do sleep 30; done
echo "[queue4] LRP ablation $(date)" >> /home/claude/queue.log
/home/claude/venv/bin/python -m medseg.explain.xai_lrp_ablation --run outputs/pannuke_resnet50 --n 60 --threads 2 > /home/claude/ablation.log 2>&1
echo "[queue4] done $(date)" >> /home/claude/queue.log
