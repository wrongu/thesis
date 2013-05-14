function [likelihood, pobj] = deriveLikelihoodMS(posneg,params)

examplesPos = zeros(length(posneg) * params.distribution_windows,1);
examplesNeg = zeros(length(posneg) * params.distribution_windows,1);

pos = 0;
neg = 0;

for idx2 = 1:length(posneg)
    
    indexPositive = find(posneg(idx2).labels == 1);
    examplesPos(pos+1:pos+length(indexPositive)) = posneg(idx2).scores(indexPositive);
    pos = pos + length(indexPositive);
    
    indexNegative = find(posneg(idx2).labels == -1);
    examplesNeg(neg+1:neg+length(indexNegative)) = posneg(idx2).scores(indexNegative);
    neg = neg + length(indexNegative);
    
end

examplesPos(pos+1:end) = [];
examplesNeg(neg+1:end) = [];

pobj = pos/(pos+neg);

posLikelihood = hist(examplesPos,params.MS.bincenters)/length(examplesPos) + eps;
negLikelihood = hist(examplesNeg,params.MS.bincenters)/length(examplesNeg) + eps;

likelihood = [posLikelihood;negLikelihood];
end