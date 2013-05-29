function h = plot_test_result(tests, cues)
h = figure();
success = arrayfun(@(r) mean([tests(r,:).percent]), 1:size(tests,1));
w = [tests(:,1).W];
semilogx(w, success*100);

title(sprintf('Test for cues %s', horzcat(cues{:})));
xlabel('Num Windows');
ylabel('Percent of Ground Truth Boxes Covered');
end