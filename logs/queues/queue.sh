#!/bin/bash
cd /home/claude/medseg-rai
PY=/home/claude/venv/bin/python
L=/home/claude
echo "[queue] stage 1 LRP add-on A $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_lrp_addon --run outputs/pannuke_resnet50 --threads 2 > $L/addon_a.log 2>&1
echo "[queue] waiting for model B $(date)" >> $L/queue.log
while [ ! -f outputs/pannuke_fpn_r18_fold1/summary.json ]; do sleep 30; done
echo "[queue] stage 2 audit B $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_fpn_r18_fold1 --fold 1 --per-tissue 20 --lrp --threads 2 > $L/audit_b.log 2>&1
echo "[queue] stage 3 MoNuSeg $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_resnet50 --dataset monuseg --per-tissue 40 --lrp --out-name rows_monuseg.csv --threads 2 > $L/audit_c.log 2>&1
echo "[queue] stage 4 dark extras A $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_resnet50 --fold 3 --only-dark --exclude-csv rows.csv --lrp --out-name rows_dark.csv --threads 2 > $L/audit_a_dark.log 2>&1
echo "[queue] stage 5 dark extras B $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_fpn_r18_fold1 --fold 1 --only-dark --exclude-csv rows.csv --lrp --out-name rows_dark.csv --threads 2 > $L/audit_b_dark.log 2>&1
echo "[queue] all done $(date)" >> $L/queue.log
