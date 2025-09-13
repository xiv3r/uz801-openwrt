Where to extract the firmware: 
- qcom-msm8916-XXX-uz801-firmware comes from modem partition
- qcom-msm8916-wcnss-uz801-nv comes from persist partition
- Its easy to extract from modem partition via mcopy, but its not that easy to automate the extraction from persist as it implies mounting an ext4 partition... so the extracted firmware is also provided.