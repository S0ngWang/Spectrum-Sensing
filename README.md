# Spectrum-Sensing
Graphical model in spectrum sensing and prediction

This project aims to apply machine learning alogrithm to cognitive radio system and enable CR users to perform 
efficient spectrum sensing & prediction. It utilizes the temproal and spectral dependencies within subbands 
and builds graphical models for inference and predicion.

·Quantified the dependencies within observed power vector in Cooperative Spectrum Sensing (CSS) system 
 and the ground truth of occupancies of subbands.
·Projected the power vector and occupancies to a Undirected Graphical Model (UGM) based on said dependencies
·Captrued the temproal dependencies between consecutive occpuancies states using Hidden Markov Model (HMM)
·Developed a mechanism that trains UGM and HMM parameter on histrical data and efficiently infers and predicts hidden states 
 of subbands with partial sensing results based on UGM and HMM
