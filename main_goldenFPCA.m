%% This script adresses the fairness concern in dimension reduction by means of a PCA-based approach
% The fairness measure is given by the difference between the reconstruction errors of the considered sensitive attributes.
% The performance measure is given by the (total) reconstruction error
% Both objectives are weighted in the (mono-objective) optimization
% We use PCA-based approach with an analytic solution, which depends on the weights associated with both objectives
% We consider the following datasets:
% - Taiwanese Default Credit: Yeh, I. C., & Lien, C. H. (2009). The comparisons of data mining techniques for the
%   predictive accuracy of probability of default of credit card clients. Expert Systems with Applications, 36(2), 2473-2480.
% - Labeled Faces in the Wild (LFW): Huang, G. B., Mattar, M., Berg, T., & Learned-Miller, E. (2008). Labeled faces
%   in the wild: A database for studying face recognition in unconstrained environments. In Workshop on Faces in 'Real-Life'
%   Images: Detection, Alignment, and Recognition. Marseille, France.
% - Statlog (German Credit): https://archive.ics.uci.edu/ml/datasets/statlog+(german+credit+data)
% - Statlog (Heart): https://archive.ics.uci.edu/ml/datasets/statlog+(heart)
% - LSAC: http://www.seaphe.org/databases.php
% - Bank Marketing: https://archive.ics.uci.edu/ml/datasets/bank+marketing
% We compare our proposal with [Samadi et al. (2018). The price of fair pca: One extra dimension. In Advances in Neural Information
% Processing Systems, p. 10976-10987] and [A novel multi-objective-based approach to analyze trade-offs in Fair Principal
% Component Analysis. ArXiv preprint, arXiv:2006.06137]. We also borrowed some codes from these papers.

clc; clear all; close all;

%% Input data and parameters
% Choose one of the following datasets to load
[M, A, B, A_orig, B_orig] = creditProcess_mono(); m_used = 22; % Education as the sensitive attributes
% [M, A, B, A_orig, B_orig] = creditProcess_mono_eq(); m_used = 22; % Education as the sensitive attributes
% [M, A, B, A_orig, B_orig] = LFWProcess_mono(); m_used = 15; % Gender as the sensitive attributes
% [M, A, B, A_orig, B_orig] = LFWProcess_mono_eq(); m_used = 15; % Gender as the sensitive attributes
% [M, A, B, A_orig, B_orig] = lsac_bwProcess_mono(); m_used = 10; % Race as the sensitive attributes
% [M, A, B, A_orig, B_orig] = lsac_bwProcess_mono_eq(); m_used = 10; % Race as the sensitive attributes
% [M, A, B, A_orig, B_orig] = bankProcess_mono(); m_used = 15; % Education as the sensitive attributes
% [M, A, B, A_orig, B_orig] = bankProcess_mono_eq(); m_used = 15; % Education as the sensitive attributes
% [M, A, B, A_orig, B_orig] = germanProcess_mono(); m_used = 19; % Gender as the sensitive attributes
% [M, A, B, A_orig, B_orig] = germanProcess_mono_eq(); m_used = 19; % Gender as the sensitive attributes
% [M, A, B, A_orig, B_orig] = heartProcess_mono(); m_used = 12; % Gender as the sensitive attributes
% [M, A, B, A_orig, B_orig] = heartProcess_mono_eq(); m_used = 12; % Gender as the sensitive attributes

%% Number of samples and attributes
[n,m] = size(M); % Number of samples (total) and features
na = size(A,1); % Number of samples in sensitive group A
nb = size(B,1); % Number of samples in sensitive group B

%% Define the maximum number of attributes to be analyzed
% m_used = min([max([m/2,10]),20]);

%% Non-supervised PCA for all classes
coeff = pca(M); % Eigenvectors coefficients

%% Mono-objective Optimization

% Experiment
time = zeros(m_used,1);
covM = (M'*M)/n;

alpha0 = 0;
alpha1 = 1;
for jj=1:m_used
    tic
    
    % Projection matrix (PCA)
    proj_pca = coeff(:,1:jj)*coeff(:,1:jj)';
    
    % Reconstruction erros for classical PCA
    rec_pca(jj) = re(M,M*proj_pca)/n;
    recA_pca(jj) = re(A_orig,A_orig*proj_pca)/na;
    recB_pca(jj) = re(B_orig,B_orig*proj_pca)/nb;
    rec_difs_pca(jj) = (recB_pca(jj) - recA_pca(jj))^2; % Calculate the squared difference
    
    % Defining the privileged group
    if recA_pca(jj) <= recB_pca(jj)
        dif_cov = (B_orig'*B_orig)/nb - (A_orig'*A_orig)/na;
    else
        dif_cov = (A_orig'*A_orig)/na - (B_orig'*B_orig)/nb;
    end
    
%     [alpha(jj),recA(jj),recB(jj),rec(jj),rec_difs(jj)] = golden_section_function(alpha0,alpha1,covM,dif_cov,M,A_orig,B_orig,m,n,na,nb,jj);
    [alpha(jj),recA(jj),recB(jj),rec(jj),rec_difs(jj)] = golden_section_function_constr(alpha0,alpha1,covM,dif_cov,M,A_orig,B_orig,m,n,na,nb,jj,max(recA_pca(jj),recB_pca(jj)));
    
    time(jj) = toc;
    jj
end

%% Figure

% Reconstruction error
figure; plot(1:m_used, rec_pca(1,:),'kx-', 1:m_used, rec,'ro-');
legend('PCA','Fair PCA'); xlabel('Number of features'); ylabel('Reconstruction error');

% Fairness measure - PCA and Fair PCA
figure; plot(1:m_used, rec_difs_pca(1,:),'kx-', 1:m_used, rec_difs, 'ro--');
legend('PCA','Fair PCA'); xlabel('Number of features'); ylabel('Fairness measure');

% Reconstruction erros for each class (PCA)
figure; plot(1:m_used, recA_pca(1,:),'g*-', 1:m_used, recB_pca(1,:), 'bs-');
legend('Group A','Group B'); xlabel('Number of features'); ylabel('Reconstruction error');

% Reconstruction erros for each class (MOFPCA)
figure; plot(1:m_used, recA,'g*-', 1:m_used, recB, 'bs-');
legend('Group A','Group B'); xlabel('Number of features'); ylabel('Reconstruction error');
