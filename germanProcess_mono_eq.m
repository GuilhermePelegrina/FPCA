function [M, A, B, A_orig, B_orig] = germanProcess_mono_eq()

% Preprocess the Taiwanese Credit dataset and return the centered/normalized data matrix M (with al samples)
% and the samples of each sensitive group A and B. 

addpath data/german_credit

data = csvread('german.csv');

% Vector of sensitive attributes
sensitive = data(:,9);

% Define the sensitive attribute: 1 for male and 0 for female
normalized = (sensitive==1)+(sensitive==3)+(sensitive==4);

% Extract the sensitive attribute from the dataset
data = data(:,[1:8,10:end-1]);

% Ddata for male
data_male = data(find(normalized),:);

% Data for female
data_female = data(find(~normalized),:);

aux = min([size(data_male,1),size(data_female,1)]);

data_male = data_male(1:aux,:);
data_female = data_female(1:aux,:);
data = [data_male; data_female];

[m,n] = size(data); % Number of attributes

% Centering and normalizing the dataset
data = (data - repmat(mean(data),m,1))./repmat(std(data),m,1);

B_orig = data(1:aux,:);
A_orig = data(aux+1:end,:);

data_male = B_orig;
data_female = A_orig;

% Centering and normalizing the sensitive attributes
data_female = (data_female - repmat(mean(data_female),size(data_female,1),1));
data_male = (data_male - repmat(mean(data_male),size(data_male,1),1));

M = data;
A = data_female;
B = data_male;

end
