function scoreBayes = integrateBayes(cues,score,params)

likelihood = cell(1,length(cues));

for cue_id = 1:length(cues)    
    
    switch upper(cues{cue_id})
        
        case 'MS'
            struct = load(fullfile(params.data, 'MSlikelihood.mat'));        
            likelihood{cue_id} = struct.likelihood;
    
        case 'CC'           
            struct = load(fullfile(params.data, 'CClikelihood.mat'));
            likelihood{cue_id} = struct.likelihood;

        case 'ED'            
            struct = load(fullfile(params.data, 'EDlikelihood.mat'));
            likelihood{cue_id} = struct.likelihood;                   
            
        case 'SS'            
            struct = load(fullfile(params.data, 'SSlikelihood.mat'));
            likelihood{cue_id} = struct.likelihood;
        
        case 'OFD'
            struct = load(fullfile(params.data, 'OFDlikelihood.mat'));
            likelihood{cue_id} = struct.likelihood;
        case 'OFM'
            struct = load(fullfile(params.data, 'OFMlikelihood.mat'));
            likelihood{cue_id} = struct.likelihood;
        case 'MOS'
            struct = load(fullfile(params.data, 'MOSlikelihood.mat'));
            likelihood{cue_id} = struct.likelihood;
        otherwise
            display('error: cue name unknown')            
    end
end

binNumber = cell(1,length(cues));

for cue_id = 1:length(cues)
    
    switch upper(cues{cue_id})
        
        case 'MS'
            binNumber{cue_id} = max(min(ceil(score(:,cue_id)+0.5),params.MS.numberBins+1),1);
            
        case 'CC'
            binNumber{cue_id} = max(min(ceil(score(:,cue_id)*100+0.5),params.CC.numberBins+1),1);
            
        case 'ED'
            binNumber{cue_id} = max(min(ceil(score(:,cue_id)*2+0.5),params.ED.numberBins+1),1);
                    
        case 'SS'
            binNumber{cue_id} = max(min(ceil(score(:,cue_id)*100+0.5),params.SS.numberBins+1),1);
            
        case 'OFD'
            binNumber{cue_id} = max(min(ceil(score(:,cue_id)*100+0.5),params.OFD.numberBins+1),1);
            
        case 'OFM'
            binNumber{cue_id} = max(min(ceil(score(:,cue_id)*100+0.5),params.OFM.numberBins+1),1);
            
        case 'MOS'
            binNumber{cue_id} = max(min(ceil(score(:,cue_id)*100+0.5),params.MOS.numberBins+1),1);
        otherwise
            display('error: cue name unknown');
    end
end


pObj = params.pobj;
scoreBayes = zeros(size(score,1),1);

for bb_id=1:size(score,1)
    
    tempPos = 1;
    tempNeg = 1;
    
    for cue_id = 1:length(cues)
        tempPos = tempPos * likelihood{cue_id}(1,binNumber{cue_id}(bb_id));
        tempNeg = tempNeg * likelihood{cue_id}(2,binNumber{cue_id}(bb_id));
    end
    
    denominator = (tempPos * pObj + tempNeg * (1-pObj));
    if(denominator)
        scoreBayes(bb_id) = tempPos * pObj /(tempPos * pObj + tempNeg * (1-pObj));
    end
    
end

scoreBayes = scoreBayes+eps;

end