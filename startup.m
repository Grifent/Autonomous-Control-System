%% setup enviroment
clear all;

load('complexMap_air_ground_new.mat');
load('obstacles_air_ground.mat');
 
homedir = pwd;

addpath( genpath(strcat(homedir,[filesep,'toolboxes'])));

cd('toolboxes/MRTB');
startMobileRoboticsSimulationToolbox;

cd(homedir);

logical_map = rot90(logical_map,3);

%% Generate (or load) waypoints
waypoints = genWaypoints(5, logical_map,obstacles);
% load('waypointsTest.mat');

%% Open sim
close_system('sl_groundvehicleDynamics',0);
open_system('sl_groundvehicleDynamics');

cd(homedir);

%% Run sim
% waypoints2 = organiseWP_NN(waypoints); 

waypoints = organiseWP(waypoints, logical_map);  % SORTS THE WAYPOINTS INTO BEST ORDER (MUST BE RUN)

data = sim('sl_groundvehicleDynamics');
