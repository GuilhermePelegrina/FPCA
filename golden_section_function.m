%% This function finds the minimum of a unimodal function
% We consider the golden section search algorithm

function [alpha,recA,recB,rec,rec_difs] = golden_section_function(alpha0,alpha1,covM,dif_cov,M,A_orig,B_orig,m,n,na,nb,jj)

% Default parameters
tol = 10^(-6); % Tolerance
g_ratio = (sqrt(5) + 1)/2; % Golden ratio

% Weighted covariance matrices
X_0 = alpha0*covM + (1-alpha0)*(dif_cov);
X_1 = alpha1*covM + (1-alpha1)*(dif_cov);

% Eigenvector/value decomposition
[V_0,D_0] = eig(X_0); V_0 = V_0(:,m+1-[1:m]); d_aux = diag(D_0); D_0(1:m+1:end) = d_aux(m+1-[1:m]);
[V_1,D_1] = eig(X_1); V_1 = V_1(:,m+1-[1:m]); d_aux = diag(D_1); D_1(1:m+1:end) = d_aux(m+1-[1:m]);

% Projection matrix (proposal)
proj_0 = V_0(:,1:jj)*V_0(:,1:jj)';
proj_1 = V_1(:,1:jj)*V_1(:,1:jj)';

% Reconstruction errors for the proposed approach
recA_0 = re(A_orig,A_orig*proj_0)/na;
recB_0 = re(B_orig,B_orig*proj_0)/nb;
rec_0 = re(M,M*proj_0)/n;
rec_difs_0 = (recB_0 - recA_0)^2;

recA_1 = re(A_orig,A_orig*proj_1)/na;
recB_1 = re(B_orig,B_orig*proj_1)/nb;
rec_1 = re(M,M*proj_1)/n;
rec_difs_1 = (recB_1 - recA_1)^2;

while abs(alpha1-alpha0) > tol
    
    % Novel points
    alpha0_aux = alpha1 - (alpha1-alpha0)/g_ratio;
    alpha1_aux = alpha0 + (alpha1-alpha0)/g_ratio;
    
    % Weighted covariance matrices
    X_0 = alpha0_aux*covM + (1-alpha0_aux)*(dif_cov);
    X_1 = alpha1_aux*covM + (1-alpha1_aux)*(dif_cov);
    
    % Eigenvector/value decomposition
    [V_0,D_0] = eig(X_0); V_0 = V_0(:,m+1-[1:m]); d_aux = diag(D_0); D_0(1:m+1:end) = d_aux(m+1-[1:m]);
    [V_1,D_1] = eig(X_1); V_1 = V_1(:,m+1-[1:m]); d_aux = diag(D_1); D_1(1:m+1:end) = d_aux(m+1-[1:m]);
    
    % Projection matrix (proposal)
    proj_0 = V_0(:,1:jj)*V_0(:,1:jj)';
    proj_1 = V_1(:,1:jj)*V_1(:,1:jj)';
    
    % Reconstruction erros for the proposed approach
    recA_0 = re(A_orig,A_orig*proj_0)/na;
    recB_0 = re(B_orig,B_orig*proj_0)/nb;
    rec_0 = re(M,M*proj_0)/n;
    rec_difs_0 = (recB_0 - recA_0)^2;
    
    recA_1 = re(A_orig,A_orig*proj_1)/na;
    recB_1 = re(B_orig,B_orig*proj_1)/nb;
    rec_1 = re(M,M*proj_1)/n;
    rec_difs_1 = (recB_1 - recA_1)^2;
    
    if rec_difs_0 < rec_difs_1
        alpha1 = alpha1_aux;
    else
        alpha0 = alpha0_aux;
    end
end

alpha = (alpha1 + alpha0)/2;

% Weighted covariance matrices
X = alpha*covM + (1-alpha)*(dif_cov);

% Eigenvector/value decomposition
[V,D] = eig(X); V = V(:,m+1-[1:m]); d_aux = diag(D); D(1:m+1:end) = d_aux(m+1-[1:m]);

% Projection matrix (proposal)
proj = V(:,1:jj)*V(:,1:jj)';

% Reconstruction erros for the proposed approach
recA = re(A_orig,A_orig*proj)/na;
recB = re(B_orig,B_orig*proj)/nb;
rec = re(M,M*proj)/n;
rec_difs = (recB - recA)^2;

end

