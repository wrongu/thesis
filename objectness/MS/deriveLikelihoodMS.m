function [likelihood, pobj] = deriveLikelihoodMS(posneg,params)

	examplesPosCell = cell(1, length(posneg));
	examplesNegCell = cell(1, length(posneg));
%examplesPos = zeros(length(posneg) * params.distribution_windows,1);
%examplesNeg = zeros(length(posneg) * params.distribution_windows,1);

pos = 0;
neg = 0;

parfor idx = 1:length(posneg)
    
    indexPositive = find(posneg(idx).labels == 1);
    examplesPosCell{idx} = posneg(idx).scores(indexPositive);
    pos = pos + length(indexPositive);
    
    indexNegative = find(posneg(idx).labels == -1);
    examplesNegCell{idx} = posneg(idx).scores(indexNegative);
    neg = neg + length(indexNegative);
    
end

	examplesPos = vertcat(examplesPosCell{:});
	examplesNeg = vertcat(examplesNegCell{:});

pobj = pos/(pos+neg);

posLikelihood = hist(examplesPos,params.MS.bincenters)/length(examplesPos) + eps;
negLikelihood = hist(examplesNeg,params.MS.bincenters)/length(examplesNeg) + eps;

likelihood = [posLikelihood;negLikelihood];
end