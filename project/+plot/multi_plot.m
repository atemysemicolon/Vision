function [f] = multi_plot(psnr, iter, burn_iter, variable, var_name, range, name, auto)

	% Set some sane defaults
	if (nargin < 8) auto = 0; end
	if (nargin < 7) name = 0; end
	if (nargin < 6) range = [1 5000 16 32]; end
	
	% Get new figure
	f = figure;
	hold on

	% Some variables
	sigma			= [0.05 0.1 0.15];
	elements		= numel(variable);
	colors_area		= [.95 .99 .99; .99 .95 .99; .99 .99 .95; .95 .99 .95];
	colors_line		= [.005 .7 .7; .7 .005 .7; .7 .7 .005; .005 .7 .005];
	color_burn		= [.5 .005 .005 ];
	plots			= zeros(1,3);
	areas			= zeros(1,3);

	% Find the maximum height of all the psnr's
	top = 0;
	bottom = 9999999;
	for i = 1:elements
		top			= max(top, max(psnr{i}));
		bottom		= min(bottom, min(psnr{i}));
	end

	% Get dimensions of figure
	padding		= (top - bottom) / 10;
	max_h		= top + padding;
	min_h		= bottom;

	% For each sigma, set data
	for k = 1:elements

		% Get the accumulative sum of iters
		iter_sum	= [1 cumsum(iter{k})];
		c = colors_area(k,:);

		% For each second iter, paint a gray box
		for i = 1:2:(numel(iter{k}))
			x = iter_sum(i):(iter_sum(i+1)-1);
			H = area(x, psnr{k}(x));
			h = get(H,'children');
			set(H,'FaceColor',c.^3,'EdgeColor',c.^3)
		end

		% Get saturated area color
		H = area([0 0], [0 0]);
		set(H,'FaceColor',c.^6,'EdgeColor',c.^6)
		areas(k) = H;

		% For each other second iter, paint a white box
		for i = 2:2:(numel(iter{k}))
			x = iter_sum(i):(iter_sum(i+1)-1);
			H = area(x, psnr{k}(x));
			h = get(H,'children');
			set(H,'FaceColor',c,'EdgeColor',c)
		end


		% Now plot the psnr
		x = 1:numel(psnr{k});
		plots(k) = plot(x, psnr{k}(x),'Color',colors_line(k,:));
		axis(range)

		% Plot the burn-in cutoff
		psnr{elements + 1}(burn_iter{3}) = min_h;
		line([burn_iter{k} burn_iter{k}], [psnr{k+1}(burn_iter{k}) psnr{k}(burn_iter{k})], 'Color', color_burn);

	end

	% End hold
	hold off

	% Set background to white
	set(gcf, 'Color', 'w');

	% Make axis stay on top of areas
	set(gca,'Layer','top')

	% Add axis labels
	xlabel('Conjugate Gradients Iterations');
	ylabel('psnr');

	legend_text = {};
	for i = 1:elements
		legend_text{i} = [var_name, ' = ', num2str(variable(i))];
	end

	% Set legend
	legend(areas, legend_text, 'Location', 'SouthEast');

	% If name is set, export
	if (name ~= 0) 
		plot.save_fig(f, name); 
	end

	% pause and close
	if (auto == 0) pause(); end
	close();
end
