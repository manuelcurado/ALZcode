function [ G ] = EMD2Graph( filename,k )
% Import EMD file from node2vec 
% Return KNN graph

 F = dlmread(filename);
 Fs = sortrows(F);
 Fs = Fs(1:end-1,2:end); % Select data 
 G = KNNGraphFromPoints(Fs,k);
end

