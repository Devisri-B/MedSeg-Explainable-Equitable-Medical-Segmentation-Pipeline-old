#!/bin/bash
# Strictly one heavy process at a time (8 GB machine, ~3 GB per job). Each stage resumes if interrupted.
cd /home/claude/medseg-rai
PY=/home/claude/venv/bin/python
L=/home/claude
while kill -0 929 2>/dev/null; do sleep 20; done     # let the running depth sweep finish
echo "[queue5] train model B $(date)" >> $L/queue.log
if [ ! -f outputs/pannuke_fpn_r18_fold1/summary.json ]; then
  $PY -m medseg.train --config configs/audit_fpn_r18_fold1.yaml --num-workers 0 > $L/train_b.log 2>&1
fi
echo "[queue5] LRP add-on A $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_lrp_addon --run outputs/pannuke_resnet50 --threads 2 > $L/addon_a.log 2>&1
echo "[queue5] audit B $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_fpn_r18_fold1 --fold 1 --per-tissue 15 --lrp --threads 2 > $L/audit_b.log 2>&1
echo "[queue5] MoNuSeg $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_resnet50 --dataset monuseg --per-tissue 25 --lrp --out-name rows_monuseg.csv --threads 2 > $L/audit_c.log 2>&1
echo "[queue5] dark A $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_resnet50 --fold 3 --only-dark --exclude-csv rows.csv --lrp --limit 50 --out-name rows_dark.csv --threads 2 > $L/audit_a_dark.log 2>&1
echo "[queue5] dark B $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_fpn_r18_fold1 --fold 1 --only-dark --exclude-csv rows.csv --lrp --limit 50 --out-name rows_dark.csv --threads 2 > $L/audit_b_dark.log 2>&1
echo "[queue5] LRP ablation $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_lrp_ablation --run outputs/pannuke_resnet50 --n 60 --threads 2 > $L/ablation.log 2>&1
echo "[queue5] all done $(date)" >> $L/queue.log
