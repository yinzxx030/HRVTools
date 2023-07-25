%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Copyright (C) 2010, John T. Ramshur, jramshur@gmail.com
% 
% This file is part of HRVAS
%
% HRVAS is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% HRVAS is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with HRVAS.  If not, see <http://www.gnu.org/licenses/>.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [nibi,art]=preProcessIBI(ibi, varargin)
% preProcessIBI: detects ectopic IBI, corrects ectopic IBI, and then 
% detrends IBI
%
% TODO: build function description and usage

    %% PARSE INPUTS
    p = inputParser;   % Create instance of inputParser class.
    p.addRequired('ibi', @(x)size(x,1)>1);
    %Detect/Locate artifacts settings
    p.addParamValue('locateMethod', {}, @iscell);
    p.addParamValue('locateInput', [], @ismatrix);
    %Correction/replace artifacts
    p.addParamValue('replaceMethod', 'None', ...
        @(x)any(strcmpi(x,{'none','mean','spline', ...
        'median'})));
    p.addParamValue('replaceInput', @(x)mod(x,1)==0);
    p.parse(ibi, varargin{:});
    opt=p.Results;
    
    %% correct ectopic ibi
    [nibi,art]=correctEctopic(ibi,opt);
        
end

function [nibi,art]=correctEctopic(ibi,opt)
    y=ibi(:,2);
    t=ibi(:,1);
    %locate ectopic
    if any(cell2mat(strfind(lower(opt.locateMethod),'percent')))
        i=find(ismember(opt.locateMethod, 'percent')==1);
        artPer=locateOutliers(t,y,'percent',opt.locateInput(i));
    else
        artPer=false(size(y,1),1);
    end
    if any(cell2mat(strfind(lower(opt.locateMethod),'sd')))
        i=find(ismember(opt.locateMethod, 'sd')==1)+1;
        artSD=locateOutliers(t,y,'sd',opt.locateInput(i));
    else
        artSD=false(size(y,1),1);
    end
    if any(cell2mat(strfind(lower(opt.locateMethod),'median')))
        i=find(ismember(opt.locateMethod, 'median')==1)+2;
        artMed=locateOutliers(t,y,'median',opt.locateInput(i));
    else
        artMed=false(size(y,1),1);
    end
    art=artPer | artSD | artMed; %combine all logical arrays 合并所有结果中异常值索引   
    
    %replace ectopic
     switch lower(opt.replaceMethod)
        case 'mean'
            [y t]=replaceOutliers(t,y,art,'mean',opt.replaceInput);
        case 'median'
            [y t]=replaceOutliers(t,y,art,'median',opt.replaceInput);
        case 'spline'
            [y t]=replaceOutliers(t,y,art,'cubic');
        case 'remove'
            [y t]=replaceOutliers(t,y,art,'remove');            
        otherwise %none
            %do nothing
     end
    
     nibi=[t,y];
end
