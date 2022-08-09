figure; widerthantall;
f = dir('rp_*.txt');
for i = 1:length(f)
    if ~isempty(f)
        set(gcf, 'Name', ['Motion Parameters for: ' f(i).name]);
        mot = dlmread(f(i).name);

        subplot(2,1,1);
        plot(mot(:,1:3));
        legend('X', 'Y', 'Z', 'Location', 'Best');
        set(gca, 'FontSize', 8);
        xlabel('Volume #');
        ylabel('mm');
        ylim([-3 3]);

        subplot(2,1,2);
        plot(mot(:,4:6)*100);
        legend('Pitch', 'Roll', 'Yaw', 'Location', 'Best');
        set(gca, 'FontSize', 8);
        xlabel('Volume #');
        ylabel('deg');
        ylim([-3 3]);

        waitforbuttonpress;
    end
end