function [M, A, B, A_orig, B_orig] = heartProcess_mono()

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

[m,n] = size(data); % Number of attributes

% Centering and normalizing the dataset
data = (data - repmat(mean(data),m,1))./repmat(std(data),m,1);

% Data for sensitive group 1
data_male = data(find(normalized),:);

% Data for sensitive group 2
data_female = data(find(~normalized),:);

% Centering and normalizing the sensitive attributes
data_female = (data_female - repmat(mean(data_female),size(data_female,1),1));
data_male = (data_male - repmat(mean(data_male),size(data_male,1),1));

M = data;
B_orig = M(find(normalized),:);
A_orig = M(find(~normalized),:);
A = data_female;
B = data_male;

end
