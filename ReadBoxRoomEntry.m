function [ins,outs] = ReadBoxRoomEntry

gsheet = GetGoogleSpreadsheet_NoCookies('1SJgjQWZsRLgB6dm0gV5IHnhHKLGrtwMdmQiC9CfbFmY');

numblankrows = 2;
counter = 1;
for a = 1+numblankrows:size(gsheet,1)
    ins(counter) = datetime([gsheet{a,1} ' ' gsheet{a,2}],'InputFormat','MM/dd/uuuu hh:mm:ss aa');
    outs(counter) = datetime([gsheet{a,4} ' ' gsheet{a,5}],'InputFormat','MM/dd/uuuu hh:mm:ss aa');
    
    if isnat(outs(counter))%if out was not put in, assume out was an hour after in
        outs(counter) = ins(counter)+hours(1);
    end
    
    counter = counter+1;
end

