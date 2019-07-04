function [G,Fs ] = EMD2Graph( filename,k )
% Sco 2017
% Import EMD file from node2vec 
% Return KNN graph

 F = dlmread(filename);
 Fs = sortrows(F);
 Fs = Fs(1:end-1,2:end); % Select data 
 G = KnnGraphfromPoints(k,Fs);
end

