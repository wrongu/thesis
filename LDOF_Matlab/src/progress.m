function progress(Info, a, b)
%%%%%%%%%% progress(Info, a, b)

	if a==1
		fprintf('%s: %06d of %06d',Info, a,b);
	else
		fprintf('\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b%06d of %06d', a,b);
	end

	if a==b
		fprintf('\n');
	end

end