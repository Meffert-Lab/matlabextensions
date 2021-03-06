%
%  S100 Cleaner
%  Sreenivas Eadara (written for the Meffert Lab)
%
%
%  Installation:
%
%  - Copy this file into the XTensions folder in the Imaris installation directory.
%  - You will find this function in the Image Processing menu
%
%    <CustomTools>
%      <Menu>
%         <Submenu name="Spots Functions">        
%        <Item name="S100 Cleaner" icon="Matlab" tooltip="Delete redundant S100 spots">
%          <Command>MatlabXT::S100Cleaner(%i)</Command>
%        </Item>
%         </Submenu>
%      </Menu>
%    </CustomTools>
% 
%
%  Description:
%  Delete spots from 'Lin28 in S100' that are already in MAP2.
%

function S100Cleaner(aImarisApplicationID, PrimaryChannelName, SecondaryChannelName)

% MAP2 is Primary Channel
% S100 is Secondary Channel


% connect to Imaris interface
if ~isa(aImarisApplicationID, 'Imaris.IApplicationPrxHelper')
  javaaddpath ImarisLib.jar
  vImarisLib = ImarisLib;
  if ischar(aImarisApplicationID)
    aImarisApplicationID = round(str2double(aImarisApplicationID));
  end
  vImarisApplication = vImarisLib.GetApplication(aImarisApplicationID);
else
  vImarisApplication = aImarisApplicationID;
end

aSurpassScene = vImarisApplication.GetSurpassScene();
numObjects = aSurpassScene.GetNumberOfChildren();
for a = numObjects:-1:1
    S100Object = aSurpassScene.GetChild(a-1);
    if vImarisApplication.GetFactory.IsSpots(S100Object) && endsWith(string(S100Object.GetName()), sprintf('%s %s', 'inside', SecondaryChannelName), 'IgnoreCase', true)
        break;
    end
end

for b = numObjects:-1:1
    MAP2Object = aSurpassScene.GetChild(b-1);
    if vImarisApplication.GetFactory.IsSpots(MAP2Object) && endsWith(string(MAP2Object.GetName()), sprintf('%s %s', 'inside', PrimaryChannelName), 'IgnoreCase', true)
        break;
    end
end
if not(endsWith(string(S100Object.GetName()), sprintf('%s %s', 'inside', SecondaryChannelName), 'IgnoreCase', true) && ...
        endsWith(string(MAP2Object.GetName()), sprintf('%s %s', 'inside', PrimaryChannelName), 'IgnoreCase', true))
    msgbox(sprintf('Please create %s and %s spots inside Lin28!', PrimaryChannelName, SecondaryChannelName));
    return;
end


S100Spots = vImarisApplication.GetFactory.ToSpots(S100Object);
S100SpotsCoords = S100Spots.GetPositionsXYZ();
S100IndicesT = S100Spots.GetIndicesT();
S100RadiiXYZ = S100Spots.GetRadiiXYZ();

MAP2Spots = vImarisApplication.GetFactory.ToSpots(MAP2Object);
MAP2SpotsCoords = MAP2Spots.GetPositionsXYZ();

if size(MAP2SpotsCoords, 1) == 1
    for j=1:size(S100SpotsCoords, 1) - 1
        if MAP2SpotsCoords(1,:) == S100SpotsCoords(j,:)
            S100SpotsCoords(j,:) = [];
            S100IndicesT(j,:) = [];
            S100RadiiXYZ(j,:) = [];
        end
    end
end

for i=1:size(MAP2SpotsCoords, 1) - 1
    for j=1:size(S100SpotsCoords, 1) - 1
        if MAP2SpotsCoords(i,:) == S100SpotsCoords(j,:)
            S100SpotsCoords(j,:) = [];
            S100IndicesT(j,:) = [];
            S100RadiiXYZ(j,:) = [];
        end
    end
end

%S100SpotsCoords = S100SpotsCoords(~cellfun('isempty', struct2cell(S100SpotsCoords)));
%S100IndicesT = S100IndicesT(~cellfun('isempty', struct2cell(S100IndicesT)));
%S100RadiiXYZ = S100RadiiXYZ(~cellfun('isempty', struct2cell(S100RadiiXYZ)));

S100Spots.Set(S100SpotsCoords(:,:), S100IndicesT(:,:), S100RadiiXYZ(:,1));
S100Spots.SetRadiiXYZ(S100RadiiXYZ(:,:));