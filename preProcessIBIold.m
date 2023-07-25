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
    p.addParamValue('locateMethod', [], @ischar);
    p.addParamValue('locateInput', [], @isnumeric);
    %Correction/replace artifacts
    p.addParamValue('replaceMethod', 'None', ...
        @(x)any(strcmpi(x,{'none','mean','spline', ...
        'median'})));
    p.addParamValue('replaceInput', @(x)mod(x,1)==0);
    %other
    p.addParamValue('resampleRate', 4, @(x)x>0 && mod(x,1)==0);
    p.addParamValue('meanCorrection', false, @islogical);
    p.parse(ibi, varargin{:});
    opt=p.Results;
    
    %% correct ectopic ibi
    [nibi,art]=correctEctopic(ibi,opt);
        
end

function [nibi,art]=correctEctopic(ibi,opt)
    y=ibi(:,2);
    t=ibi(:,1);
    %locate ectopic
    if strcmp(opt.locateMethod,'sd')
        artSD=locateOutliers(t,y,'sd',opt.locateInput);
    else
        artSD=false(size(y,1),1);
    end
    
    art=artSD; 
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
