function [] = Semilog_ImageSC(x,y,C,logaxis)
%________________________________________________________________________________________________________________________
% Utilized in analysis by Kevin L. Turner
% The Pennsylvania State University, Dept. of Biomedical Engineering
% https://github.com/KL-Turner
%
% Code unchanged with the exception of this block for record keeping. All rights belong to original author
%________________________________________________________________________________________________________________________

% this function plots a matrix in manner similar to imagesc, except one axis is plotted logarithmically
% x - vector of n bin centers on x axis (length(x)=n)
% y - vector of m bin centers on y axis (length(y)=m)
% C - n-by-m matrix of values to be plotted as an image
% logaxis - which axis to plot logarithmically: 'x', 'y' or 'xy'
% 9/2018 Patrick Drew

surface(x,y,zeros(size(C)),(C),'LineStyle','none');% make a surface at points x,y, of height 0 and with colors given by the matrix C
q=gca;
q.Layer='top';% put the axes/ticks on the top layer

if strcmp(logaxis,'y')==1
    set(gca,'YScale','log');
elseif strcmp(logaxis,'x')==1
    set(gca,'XScale','log');
elseif strcmp(logaxis,'xy')==1
    set(gca,'XScale','log');
    set(gca,'YScale','log');
end
axis xy
axis tight
