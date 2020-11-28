function ints = booltoint(bool)
% Takes a boolean and creates a series of start-stop intervals (one row for
% each int, each row is [startpoint stoppoint]) based on makng ints to 
% describe any span of 1s.

ints = continuousabove2(bool,0.5,0,inf);
