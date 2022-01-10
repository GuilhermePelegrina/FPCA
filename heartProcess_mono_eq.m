function [M, A, B, A_orig, B_orig] = heartProcess_mono_eq()

% Preprocess the Taiwanese Credit dataset and return the centered/normalized data matrix M (with al samples)
% and the samples of each sensitive group A and B. 

addpath data/heart

data = csvread('heart.csv');

% Vector of sensitive attributes
sensitive = data(:,2);

% Define the sensitive attribute: 0 or 1 (the gender is unknown)
normalized = sensitive;

% Extract the sensitive attribute from the dataset
data = data(:,[1,3:end-1]);

% Data for sensitive group 1
data_s1 = data(find(normalized),:);

% Data for sensitive group 2
data_s2 = data(find(~normalized),:);

aux = min([size(data_s1,1),size(data_s2,1)]);

data_s1 = data_s1(1:aux,:);
data_s2 = data_s2(1:aux,:);
data = [data_s1; data_s2];

[m,n] = size(data); % Number of attributes

% Centering and normalizing the dataset
data = (data - repmat(mean(data),m,1))./repmat(std(data),m,1);

B_orig = data(1:aux,:);
A_orig = data(aux+1:end,:);

data_s1 = B_orig;
data_s2 = A_orig;

% Centering and normalizing the sensitive attributes
data_s2 = (data_s2 - repmat(mean(data_s2),size(data_s2,1),1));
data_s1 = (data_s1 - repmat(mean(data_s1),size(data_s1,1),1));

M = data;
A = data_s2;
B = data_s1;

end
