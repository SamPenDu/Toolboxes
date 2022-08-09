function time24h
%Returns the current time of the system clock.

c = clock;
disp(' ');
disp(['The time is ' num2str(c(4)*100 + c(5)) ' hours.']);
disp(' ');