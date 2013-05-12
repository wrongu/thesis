
root_dir=pwd;

if exist('sor_warping_flow_multichannel_LDOF', 'file') ~= 3
    
    cd([root_dir '/src/']);
    mex sor_warping_flow_multichannel_LDOF.cpp;
end

if exist('ann_mex', 'file') ~= 3
    
    cd([root_dir '/third_party/ann_mwrapper/']);
    ann_compile_mex;
    
end

cd(root_dir);