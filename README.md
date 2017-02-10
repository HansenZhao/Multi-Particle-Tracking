# Multi-Particle-Tracking
Based on Daniel Blair and Eric Dufresne's MATLAB code  
http://site.physics.georgetown.edu/matlab/index.html  
"Methods of Digital Video Microscopy for Colloidal Studies", John C. Crocker and David G. Grier, J. Colloid Interface Sci. 179, 298 (1996).  
  
Hansen Zhao: zhaohs12@163.com

### Tutorial

#### Download Zip file in this repository as well as code in web page: http://site.physics.georgetown.edu/matlab/code.html

#### Init DETracker instance

```
tr = DETracker();
```
choose your image seqence in dialog

#### Process Particle Tracking

```
tr.getPTrace( pSize, intensityRatio, isShowRes, maxVel)
```
pSize is particle size in pixel unit  
initensityRatio is the min intensity of target particle, for example, intensityRatio = 0.3 means the min intensity of a particle should higher than 0.3 * maxIntensity of the image  
isShowRes = 1 means show the result of particle location identifying in each frame, set to 0 to ignore this function  
maxVel determine the max displacement between the consecutive two frame

a pop up window require info for trace determination, type
```
help track
```
for more description

#### View result
To get the number of tracked particle,type
```
tr.traceNum
```
To set the id of particles which is to show in figure,type
```
tr.setShowId(ids)
```
ids can be an array with multi ids,type
```
tr.setShowId(1:1:tr.traceNum)
```
to show all tracked particle,type
```
tr.show();
```
to view the image sequence as well as particle trajectory
