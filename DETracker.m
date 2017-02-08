classdef DETracker < handle
    %DETracker Summary of this class goes here
    % Based on Daniel Blair and Eric Dufresne code
    % http://site.physics.georgetown.edu/matlab/index.html#contact
    % "Methods of Digital Video Microscopy for Colloidal Studies", 
    % John C. Crocker and David G. Grier, J. Colloid Interface Sci. 179, 298 (1996).
    properties
        imSeq;
        traceNum;
        showId;
    end
    
    properties(Access = private)
        particleTrace;
    end
    
    methods
        function obj = DETracker()
            obj.imSeq = imageSeq();
            obj.imSeq.listenUpdate(@(src,eventdata)obj.updateTrace(src,eventdata));
            obj.traceNum = 0;
            obj.particleTrace = [];
        end
        
        function getPTrace(obj,pSize,intensityRatio,isShowRes,maxVel)
            if isShowRes
                [loc,~]=images2pl(obj.imSeq.getImage(),pSize,intensityRatio,1);
            else
                [loc,~]=images2pl(obj.imSeq.getImage(),pSize,intensityRatio);
            end
            
            param = struct();
            answer = inputdlg({'param.mem','param.dim','param.good','param.quiet'},'param set',[1],{'0','2','0','0'});
            
            param.mem = str2num(answer{1});
            param.dim = str2num(answer{2});
            param.good = str2num(answer{3});
            param.quiet = str2num(answer{4});

            obj.particleTrace = track(loc,maxVel,param);

            obj.traceNum = max(obj.particleTrace(:,4));
            
            obj.showId = [];
            obj.imSeq.curImageIndex = 1;
        end
        
        function p = getParticle(obj,varargin)
            if obj.traceNum
                if isempty(varargin)
                    p = obj.particleTrace;
                else
                    p = obj.particleTrace(obj.particleTrace(:,4)==varargin{1},1:3);
                end
            else
                p = 0;
            end
        end
        
        function setShowId(obj,ids)
            if ids <= obj.traceNum
                obj.showId = ids;
            else
                disp('ERROR:particle ID not found!');
            end
        end
        
        function show(obj)
            obj.imSeq.show();
        end
        
    end
    
    methods(Access = private)
        function updateTrace(obj,varargin)
            if ~isempty(obj.showId)
                set(varargin{1}.getAxes(),'NextPlot','add');
                for m = 1:1:length(obj.showId)
                    tmpTrace = obj.getParticle(m);
                    plot(varargin{1}.getAxes(),tmpTrace(:,1),tmpTrace(:,2),'r');
                    curPoint = tmpTrace(tmpTrace(:,3)==varargin{1}.curImageIndex,1:2);
                    if ~isempty(curPoint)
                        scatter(curPoint(:,1),curPoint(:,2),20,'r','filled');
                    end
                end
                set(varargin{1}.getAxes(),'NextPlot','replacechildren');
            end
        end
    end
    
end

