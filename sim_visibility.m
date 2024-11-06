function vis_table = sim_visibility(tle_file, day1, t_step, n_days, a, e, i, OM, om, th, alfa

% Given TLE of a space debris and Orbital parameters of a satellite of interest, compute the visibility windows between the two objects with the MATLAB Satellite Scenario tool. Requires MATLAB Satellite Scenario.
% -------------------------------------------------------------------------
% Input arguments:
%
% tle_file : name of the text file with the TLE data (e.g. 'my_tle_file.txt'). The file should be in the same repository of this script.
% day1 [1x6] vector containing date and time of the first instant of simulation. It should be in the format [Y, M, D, H, Min, S]
% t_step [s] : time step of the simulation
% n_days [-] : number of days of simulation
% a [km] : semi-major axis of the satellite's orbit
% e [-] _ eccentricity of the satellite's orbit
% i [rad] : inclination of the satellite's orbit
% Om [rad] : RAAN of the satellite's orbit
% om [rad] : argument of perigee of the satellite's orbit
% th [rad] : true anomaly of the satellite%%
%
% -------------------------------------------------------------------------
% Output arguments:
%
% vis_table : Table of visibility intervals with columns [Satellite, Target, IntervalNumber, StartTime, EndTime, Duration, StartOrbit, EndOrbit]


Dates_vec = datetime(day1(1), day1(2), day1(3), day1(4), day1(5), day1(6),TimeZone="UTC");

startTime = Dates_vec(1);
stopTime = startTime + hours(24*n_days);
scenario = satelliteScenario(startTime, stopTime, t_step);

for j = t_step:t_step:60*60*24*n_days
    Dates_vec = [Dates_vec, datetime(day1(1), day1(2), day1(3), day1(4), day1(5), j,TimeZone="UTC")];
end


% Debris Object 

tle_debris = tleread(tle_file);

[R_deb, V_deb] = propagateOrbit(Dates_vec, tle_debris);
PosTable = timetable(Dates_vec', R_deb); % meters
VelTable = timetable(Dates_vec', V_deb); % meters/sec
debris_object = satellite(scenario, PosTable, VelTable, 'Name', 'My_Debris');


% Satellite Object


sat_object = satellite(scenario, a*1000, e, i*180/pi, Om*180/pi, om*180/pi, th*180/pi, 'OrbitPropagator', 'sgp4', 'Name','My_Sat');
[R_sat,V_sat,~] = states(sat);
Pos_sat = [R_sat',V_sat'];         % meters
g = gimbal(sat);


% Visibility

pointAt(g,debris_object);
camSensor = conicalSensor(g,MaxViewAngle=10*180/pi); 
ac = access(camSensor, debris_object);
vis_table = accessIntervals(ac);



