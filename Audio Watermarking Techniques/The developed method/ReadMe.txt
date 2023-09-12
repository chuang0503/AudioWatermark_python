Basic steps for watermarking:
1. Run Pre_process.m 
   Input: bass_half.wav
   Output: Para_embedding.dat, Wb.dat and Wo.dat
2. Modify Parameter_embedding.m according to Para_embedding.dat.
3. Run Embedding.m
   Input: bass_half.wav
   Output: watermarked_signal.wav, Wo.dat, PNs.dat, Positions.dat 
4. (Optional) Apply attacks on the watermarked_signal.wav to get the attacked signals, such as noise addition, lowpass filtering, MP3 compression, pitch shifting, time stretching, etc.
5. Run Pre_process.m on the signal to be detected
   Input: watermarked_signal.wav or an attacked signal
   Output: Para_detection.dat
6. Modify Parameter_detection.m according to Para_detection.dat 
7. Run Detection.m
   Input: watermarked_signal.wav or an attacked signal
   Output: the detected watermark We.dat