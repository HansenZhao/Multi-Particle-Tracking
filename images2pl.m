function [ location,pNum ] = images2pl(imageSeq,pSize,intensityRatio,showRes)
% Hansen Zhao : zhaohs12@163.com
% Based on Daniel Blair and Eric Dufresne code
% http://site.physics.georgetown.edu/matlab/index.html#contact
% "Methods of Digital Video Microscopy for Colloidal Studies", 
% John C. Crocker and David G. Grier, J. Colloid Interface Sci. 179, 298 (1996).
%   Detailed explanation goes here
    if nargin < 4
        showRes = 0;
    end
    imageNum = size(imageSeq,3);
    location = [];
    pNum = zeros(imageNum,1);
    colormap('gray');
    for m = 1:imageNum
        rawImage = imageSeq(:,:,m);
        passImage = bpass(rawImage,1,pSize);
        pk = pkfnd(passImage,max(passImage(:)) * intensityRatio,pSize);
        cnt = cntrd(passImage,pk,pSize);
        pNum(m) = size(cnt,1);
        location = [location;[cnt(:,1:2),ones(pNum(m),1) * m]];
        if showRes
            subplot(1,2,1);
            title(strcat('raw Image frame:',32,num2str(m)));
            imagesc(rawImage);
            subplot(1,2,2);
            title(strcat(num2str(pNum(m)),32,'particle determined'));
            imagesc(rawImage);
            hold on;
            scatter(cnt(:,1),cnt(:,2),10,'filled');
            pause
        end
    end 
end

