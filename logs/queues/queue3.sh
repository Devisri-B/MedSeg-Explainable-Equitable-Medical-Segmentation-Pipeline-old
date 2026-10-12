#!/bin/bash
# Strictly one heavy process at a time (the machine has 8 GB and each job needs about 3 GB).
cd /home/claude/medseg-rai
PY=/home/claude/venv/bin/python
L=/home/claude
echo "[queue3] LRP add-on A $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_lrp_addon --run outputs/pannuke_resnet50 --threads 2 > $L/addon_a.log 2>&1
echo "[queue3] train model B $(date)" >> $L/queue.log
if [ ! -f outputs/pannuke_fpn_r18_fold1/summary.json ]; then
  $PY -m medseg.train --config configs/audit_fpn_r18_fold1.yaml --num-workers 0 > $L/train_b.log 2>&1
fi
echo "[queue3] audit B $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_fpn_r18_fold1 --fold 1 --per-tissue 15 --lrp --threads 2 > $L/audit_b.log 2>&1
echo "[queue3] MoNuSeg $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_resnet50 --dataset monuseg --per-tissue 25 --lrp --out-name rows_monuseg.csv --threads 2 > $L/audit_c.log 2>&1
echo "[queue3] depth sweep $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_depth_sweep --run outputs/pannuke_resnet50 --n 100 --threads 2 > $L/depth.log 2>&1
echo "[queue3] dark A $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_resnet50 --fold 3 --only-dark --exclude-csv rows.csv --lrp --limit 50 --out-name rows_dark.csv --threads 2 > $L/audit_a_dark.log 2>&1
echo "[queue3] dark B $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_fpn_r18_fold1 --fold 1 --only-dark --exclude-csv rows.csv --lrp --limit 50 --out-name rows_dark.csv --threads 2 > $L/audit_b_dark.log 2>&1
echo "[queue3] all done $(date)" >> $L/queue.log
