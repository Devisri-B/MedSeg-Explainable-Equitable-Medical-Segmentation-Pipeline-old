# Run logs (October 11 to 12, 2026)

Kept for reference because the models are expensive to re-run on a 2-core, 8 GB CPU machine.
Times are US Eastern. Each stage resumes from its own results file, so several stages were started more than once;
a log file holds only the **last** run of that stage, so earlier attempts (including crashed ones) are not in it.

| Log | What it is | Approx. cost |
|---|---|---|
| `audit_main.log`, `sanity.log`, `sanity2.log`, `analysis.log` | first audit of model A (U-Net++ / ResNet-50, PanNuke fold 3), parameter-randomization check, analysis | about 15 s per image |
| `addon_a.log` | LRP columns added to the 622 images of study A (`xai_lrp_addon`) | about 28 s per image |
| `train_b.log`, `train_d.log` | training of model B (FPN / ResNet-18, folds 2+3, 3 epochs) and model D (U-Net / ResNet-18, folds 1+3, 4 epochs); `tqdm` progress bars included | about 20 min per epoch (B), 22 min per epoch (D) |
| `audit_b.log` | first pass of the study B audit (15 images per tissue) | |
| `audit_b_ext.log` | extended study B audit (up to 100 images per tissue, with LRP) | about 2.7 s per image |
| `audit_c.log`, `monuseg.log` | study C: model A on 200 MoNuSeg tiles (data preparation, then audit) | |
| `audit_a_dark.log`, `audit_b_dark.log` | extra dark-stain images for studies A and B | |
| `audit_d.log` | study D audit (60 images per tissue, with LRP) | about 3.2 s per image |
| `depth.log` | depth sweep, model A, 100 images | |
| `ablation.log` | LRP rule ablation, 60 images, three rules | about 27 s per image |
| `explorer.log` | rebuild of the interactive explorer (659 images, 114 with pictures) | about 16 min |
| `queue.log` | timestamps of each stage as the compute queue ran them | |
| `queues/*.sh` | the queue scripts that ran the stages one at a time (several were superseded after out-of-memory kills) | |

Out-of-memory note: running training and an audit at the same time exceeded the 8 GB limit and killed jobs, which is why the
queue scripts run one heavy process at a time and training uses `--num-workers 0`.

Final numbers are in `../results/replication/replication.json`.
