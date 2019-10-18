function LED = DefineTrials(whl)
LED.p = whl;
LED.trial = zeros(length(whl(:,1)),1);
trial = 0;
count0 = 0;
for i = 1:length(whl(:,1))
    if whl(i) == 0
       count0 = count0 + 1;
    elseif trial == 0 || count0 > 100
           trial = trial+1;
           count0 = 0;
           LED.trial(i) = trial;
    else
        LED.trial(i) = trial;
    end
end
