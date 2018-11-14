function [score] = FQPath(input_image, kernel_sheet)
%
%Non-reference Focus Quality Assessment (NR-FQA) metric for digital 
%pathology
%
%   [score] = FQPath(input_image, params)
%
%   returns the NR-FQA score of the input digital pathological image.
%   Higher score indicates more blurriness in the input image.
%
%
%   Input(s):
%   'input_image'           the grayscale input image for focus quality 
%                           assessment
%                   
%   'params.kernel_sheets'  the pre-designed human visual system-like 
%                           kernel that extracts the sharpness featue from
%                           the input image                  
%
%   Output(s):
%   'score'                 the NR-FQA score 
%
%
%   Copyright (c) 2018 Mahdi S. Hosseini and Yueyang Zhang
%
%   University of Toronto
%   The Edward S. Rogers Sr. Department of,
%   Electrical and Computer Engineering (ECE)
%   Toronto, ON, M5S3G4, Canada
%   Tel: +1 (416) 978 6845
%   email: mahdi.hosseini@mail.utoronto.ca

l = 16;
amp = 1;
alpha = 2;
beta = 1.5;
h_LPF = generalized_Gaussian_for_fitting([-l:l], amp, alpha, beta);
h_LPF = h_LPF/sum(h_LPF);

% do convolution
i_BP_v = imfilter(input_image, h_LPF(:)', 'symmetric', 'conv');
i_BP_v = imfilter(i_BP_v, kernel_sheet, 'symmetric', 'conv');
i_BP_h = imfilter(input_image, h_LPF(:), 'symmetric', 'conv');
i_BP_h = imfilter(i_BP_h, kernel_sheet', 'symmetric', 'conv');
mask = (i_BP_v>0) & (i_BP_h>0);
%mask = iB;
%
v = [abs(i_BP_v(mask)), abs(i_BP_h(mask))];
[pdf, x] = hist(v(:), 50);
cdf = cumsum(pdf)/sum(pdf);
% find sigma approximate
threshold = .95;
min_val = min(cdf);
max_val = max(cdf);
rng_val = max_val - min_val;
indx = cdf < min_val + threshold*rng_val;
sigma_apprx = x(sum(indx))/max(x);
c = (1-tanh(60*(sigma_apprx-.095)))/4 + 0.09;

p_norm = 1/2;
feature_map = (abs(v(:, 1)).^p_norm + abs(v(:, 2)).^p_norm).^(1/p_norm);

%%
number_of_pixels = round(c*numel(feature_map));
feature_map = sort(feature_map(:), 'descend');
feature_map = feature_map(1: number_of_pixels);

%% iterate moments
val = moment(feature_map, 4);
val = abs(val);
val = -log10(val);
if val == (-inf)
    val = 0;
elseif val == inf
    val = 120;
end
score = val;