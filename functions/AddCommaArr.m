function B = AddCommaArr(A, p)
%-------------------------------------------------------------------------%
% AddCommaArr.m
% Purpose:  Formats a numeric array as strings with two decimal places and
%           appends significance stars (* p<0.1, ** p<0.05, *** p<0.01)
%           based on t-statistics supplied in p.
% Arguments:
%   A   - numeric array of coefficient estimates
%   p   - numeric array of t-statistics (same size as A); default ones(A)
% Returns:
%   B   - string array of formatted values with significance stars
%-------------------------------------------------------------------------%

if nargin < 2
    p = ones(length(A),1);
end

B = strings(size(A));
for i = 1:size(A,1)
    for j = 1:size(A,2)
        B(i,j) = addComma(A(i,j));
    end
end

for i = 1:length(B)
    if abs(p(i)) >= 1.65 && abs(p(i)) < 1.96
        B(i) = strcat(B(i),'*');
    elseif abs(p(i)) >= 1.96 && abs(p(i)) < 2.58
        B(i) = strcat(B(i),'**');
    elseif abs(p(i)) >= 2.58
        B(i) = strcat(B(i),'***');
    end
end

function numOut = addComma(numIn)
   jf=java.text.DecimalFormat; % comma for thousands, three decimal places
   jf.setMinimumFractionDigits(2); % set minimum fraction digits to 1
   jf.setMaximumFractionDigits(2); % set maximum fraction digits to 2
   numOut= jf.format(numIn); % omit "char" if you want a string out
end
end
