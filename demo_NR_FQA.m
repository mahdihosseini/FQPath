%%
clear all;
close all;
clc;

%%
addpath('utilities');
fprintf(['==> Note that high score value indicates more blurriness in input image \n']);

%% Load image and covnert to grayscale image with single values
in_focus_img = imread('data\sample_in_focus.png');
out_of_focus_img = imread('data\sample_out_of_focus.png');

%%  transfer images into grayscale
in_focus_image = im2double(rgb2gray(in_focus_img));
out_of_focus_image = im2double(rgb2gray(out_of_focus_img));

%% Load kernel and identify image blur type
load('FQPath_kernel.mat');
kernel_sheet = FQPath_kernel{:};

%% NR-FQA Score on in-focus image
score_in_focus = FQPath(in_focus_image, kernel_sheet);
fprintf(['NR-FQA score in-focus image = ', num2str(score_in_focus), '\n']);

%% NR-FQA Score on out-of-focus image
score_out_of_focus = FQPath(out_of_focus_image, kernel_sheet);
fprintf(['NR-FQA score out-of-focus image = ', num2str(score_out_of_focus), '\n']);

%% demonstrate the sample images and the NR-FQA scores
figure(1)
subplot(1,2,1)
imshow(in_focus_img)
title(['NR-FQA score = ', num2str(score_in_focus)])
subplot(1,2,2)
imshow(out_of_focus_img)
title(['NR-FQA score = ', num2str(score_out_of_focus)])