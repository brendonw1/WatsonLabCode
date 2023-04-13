% Makes a hypnogram from the ints variable. If you don't have ints, you can
% easily make one with the function makeints in NicoletteSuite folder. It's
% in the Nice Functions to Have folder
%
% Oh, by the way, you can visualize the hypnogram by doing imagesc(MakeHypno(ints))
% Good luck, fuckers... (Sorry, it can't be a David function without profanities ;D )

function [hypno] = MakeHypno(ints)
    maxtime = max([max(ints.WAKEstate) max(ints.NREMstate) max(ints.REMstate)]);

    hypno = zeros(1,round(maxtime));
    for i = 1:length(hypno)
        for j = 1:length(ints.WAKEstate(:,1))
            if (i > ints.WAKEstate(j,1) && i < ints.WAKEstate(j,2))
                hypno(i) = .9;
            end
        end
        for j = 1:length(ints.NREMstate(:,1))
            if (i > ints.NREMstate(j,1) && i < ints.NREMstate(j,2))
                hypno(i) = 1.5;
            end
        end
        for j = 1:length(ints.REMstate(:,1))
            if (i > ints.REMstate(j,1) && i < ints.REMstate(j,2))
                hypno(i) = 2.9;
            end
        end    
    end
end