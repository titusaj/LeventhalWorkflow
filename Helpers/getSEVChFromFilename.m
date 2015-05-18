function ch = getSEVChFromFilename(name)
%Function to find the number after ch in the name of the SEV file
C = strsplit(name,'_');
C = strsplit(C{end},'.'); %C{1} = chXX
ch = str2double(C{1}(3:end));