function [M, A, B, A_orig, B_orig] = lsac_bwProcess_mono_eq()

% Preprocess the LSAC dataset and return the centered/normalized data matrix M (with al samples)
% and the samples of each sensitive group A and B. 

addpath data/lsac

data = csvread('lsac.csv');

% Removing the race "Other" 
data(data(:,6)==3,:) = [];

% Vector of sensitive attributes
sensitive = data(:,6);

% Define the sensitive attribute: 0 for black and 1 for white
normalized = (sensitive==1);

% Extract the sensitive attribute from the dataset
data = data(:,[1:5,7:end-1]);

% Data for White
data_White = data(find(normalized),:);

% Data for Black
data_Black = data(find(~normalized),:);

aux = min([size(data_White,1),size(data_Black,1)]);

data_White = data_White(1:aux,:);
data_Black = data_Black(1:aux,:);
data = [data_White; data_Black];

[m,n] = size(data); % Number of attributes

% Centering and normalizing the dataset
data = (data - repmat(mean(data),m,1))./repmat(std(data),m,1);

B_orig = data(1:aux,:);
A_orig = data(aux+1:end,:);

data_White = B_orig;
data_Black = A_orig;

% Centering and normalizing the sensitive attributes
data_Black = (data_Black - repmat(mean(data_Black),size(data_Black,1),1));
data_White = (data_White - repmat(mean(data_White),size(data_White,1),1));

M = data;
A = data_Black;
B = data_White;

end
