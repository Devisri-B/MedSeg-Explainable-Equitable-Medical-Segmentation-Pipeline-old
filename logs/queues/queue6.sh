#!/bin/bash
cd /home/claude/medseg-rai
while ! grep -q "queue5\] all done" /home/claude/queue.log; do sleep 30; done
echo "[queue6] audit B extended $(date)" >> /home/claude/queue.log
/home/claude/venv/bin/python -m medseg.explain.xai_audit --run outputs/pannuke_fpn_r18_fold1 --fold 1 --per-tissue 60 --lrp --threads 2 > /home/claude/audit_b_ext.log 2>&1
echo "[queue6] done $(date)" >> /home/claude/queue.log
