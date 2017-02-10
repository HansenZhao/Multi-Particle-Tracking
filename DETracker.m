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
        param;
        pSize;
        intensRatio;
        maxVelocity;
    end
    
    methods
        function obj = DETracker()
            obj.imSeq = imageSeq();
            obj.imSeq.listenUpdate(@(src,eventdata)obj.updateTrace(src,eventdata));
            obj.traceNum = 0;
            obj.particleTrace = [];
            obj.param = struct();
            obj.param.mem = 0;
            obj.param.dim = 2;
            obj.param.good = 0;
            obj.param.quiet = 0;
        end
        
        function getPTrace(obj,pSize,intensityRatio,isShowRes,maxVel)
            
            obj.pSize = pSize;
            obj.intensRatio = intensityRatio;
            obj.maxVelocity = maxVel;
            
            if isShowRes
                [loc,~]=images2pl(obj.imSeq.getImage(),pSize,intensityRatio,1);
            else
                [loc,~]=images2pl(obj.imSeq.getImage(),pSize,intensityRatio);
            end
            
            answer = inputdlg({'param.mem','param.dim','param.good','param.quiet'},'param set',[1],{'0','2','0','0'});
            disp(strcat('mem =',32,answer{1},32,...
                        'dim =',32,answer{2},32,...
                        'good =',32,answer{3},32,...
                        'quiet =',32,answer{4}));
            
            obj.param.mem = str2num(answer{1});
            obj.param.dim = str2num(answer{2});
            obj.param.good = str2num(answer{3});
            obj.param.quiet = str2num(answer{4});
            

            obj.particleTrace = track(loc,maxVel,obj.param);

            obj.traceNum = max(obj.particleTrace(:,4));
            
            obj.showId = [];
            obj.imSeq.curImageIndex = 1;
            disp(strcat(num2str(obj.traceNum),32,'traces has been defined!'));
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
        
        function setShowId(obj,varargin)
            
            if isempty(varargin)
                ids = 1:1:obj.traceNum;
            else
                ids = varargin{1};
            end
            
            if ids <= obj.traceNum
                obj.showId = ids;
            else
                disp('ERROR:particle ID not found!');
            end
        end
        
        function show(obj)
            obj.imSeq.show();
        end
        
        function save(obj,fileName)
            fid = fopen(strcat(obj.imSeq.sequencePath,fileName,'.csv'),'w');
            fprintf(fid,'%s\n','DETracker Particle Track Result');
            fprintf(fid,'Trace Number: %d\n',obj.traceNum);
            fprintf(fid,'Sequence Length: %d\n\n',obj.imSeq.seqLength);
            fprintf(fid,'Tracking Setting:\n');
            fprintf(fid,'Particle Size: %d\nIntensity Ratio: %3.2f\nMax Velocity: %d\n',...
                    obj.pSize,obj.intensRatio,obj.maxVelocity);
            fprintf(fid,'mem = %d, dim = %d, good = %d\n\n',obj.param.mem,obj.param.dim,obj.param.good);
            fprintf(fid,'Particle Trace Data\n');
            fprintf(fid,'X coord,Ycoord,Time index,Particle Id\n');
            L = size(obj.particleTrace,1);
            for m = 1:1:L
                tmp = obj.particleTrace(m,:);
                fprintf(fid,'%f,%f,%d,%d\n',tmp(1),tmp(2),tmp(3),tmp(4));
            end
            fclose(fid);
            fprintf(1,'Data file has been written in %s\n',strcat(obj.imSeq.sequencePath,fileName,'.csv'));
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
                        scatter(curPoint(:,1),curPoint(:,2),20,'b','filled');
                    end
                end
                set(varargin{1}.getAxes(),'NextPlot','replacechildren');
            end
        end
    end
    
end

