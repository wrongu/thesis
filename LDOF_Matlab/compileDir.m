
if exist('sor_warping_flow_multichannel_LDOF', 'file') ~= 3
    root_dir=pwd;
    
    cd([root_dir '/src/']);
    mex sor_warping_flow_multichannel_LDOF.cpp;
    
    cd([root_dir '/third_party/ann_mwrapper/']);
    ann_compile_mex;
    
    cd(root_dir);
end