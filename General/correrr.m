function snr = correrr(n)
% Simulates and plots the error magnitude vs the correlation coefficient.
%

E = 0:.5:20; 
Rs = []; 
for i = 1:1000 
    R = []; 
    for e = E 
        a = randn(n,1); 
        b = a + e*randn(n,1); 
        R = [R;corr(a,b,'type','spearman')]; 
    end; 
    Rs=[Rs R]; 
end; 

err = mean(Rs,2);
plot(E,err);
xlabel('Error magnitude');
ylabel('Correlation coefficient');