%% Receive scanner trigger to start

% % FIL setup
% CurrSlice = waitslice(Port, 1);  

% % BUCNI setup
% config_and_wait_trigger(1);

% % Obsolete CAMRI setup 
% WaitForMRITrigger;

% New CAMRI setup
[bkp, bkt, bk] = KbCheck;           
bkp = ismember(KbName('5%'), find(bk));
