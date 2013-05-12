
<<<<<<< HEAD
root_dir=pwd;

if exist('sor_warping_flow_multichannel_LDOF', 'file') ~= 3
    
    cd([root_dir '/src/']);
    mex sor_warping_flow_multichannel_LDOF.cpp;
end

if exist('ann_mex', 'file') ~= 3
=======
if exist('sor_warping_flow_multichannel_LDOF', 'file') ~= 3
    root_dir=pwd;
    
    cd([root_dir '/src/']);
    mex sor_warping_flow_multichannel_LDOF.cpp;
>>>>>>> FETCH_HEAD
    
    cd([root_dir '/third_party/ann_mwrapper/']);
    ann_compile_mex;
    
<<<<<<< HEAD
end

cd(root_dir);
=======
    cd(root_dir);
end
>>>>>>> FETCH_HEAD
