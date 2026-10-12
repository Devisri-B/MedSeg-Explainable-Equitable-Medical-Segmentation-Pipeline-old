#!/bin/bash
cd /home/claude/medseg-rai
PY=/home/claude/venv/bin/python
L=/home/claude
while ! grep -q "queue5\] all done" $L/queue.log; do sleep 30; done
echo "[queue7] audit B extended $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_fpn_r18_fold1 --fold 1 --per-tissue 100 --lrp --threads 2 > $L/audit_b_ext.log 2>&1
echo "[queue7] train model D $(date)" >> $L/queue.log
if [ ! -f outputs/pannuke_unet_r18_fold2/summary.json ]; then
  $PY -m medseg.train --config configs/audit_unet_r18_fold2.yaml --num-workers 0 > $L/train_d.log 2>&1
fi
echo "[queue7] audit D $(date)" >> $L/queue.log
$PY -m medseg.explain.xai_audit --run outputs/pannuke_unet_r18_fold2 --fold 2 --per-tissue 60 --lrp --threads 2 > $L/audit_d.log 2>&1
echo "[queue7] done $(date)" >> $L/queue.log
