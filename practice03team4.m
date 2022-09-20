% USAGE OF THIS CODE IS STRICTLY FOR REFERENCE ONLY, DO NOT COPY
% CODED BY:
% Andrea Cervantes Bonet   - 100.429.950
% Sandra de la Chica Liñán - 100.452.190
% Jorge Lázaro Ruiz        - 100.452.172

% LOADING THE DATA
disp('Loading data...');
load('population.mat','-mat');
disp('Data loaded.');
    % Converting the table into a matrix for easier access
babiesperwoman = table2array(babiesperwoman);
    % Selecting only relevant data
chosencountries = [36, 76, 96, 137, 177]; % This vector is created so that it is easier to change the countries on the fly
disp('Selecting relevant data...');
data = zeros(5,70);
for i = 1:5
    data(i,:) = babiesperwoman(chosencountries(i),:); % Copies the data from each country
end
disp('Data selected.');

% CONSTRUCTING SPLINES AND FINDING ERRORS

% We will store the coefficients in a 4D matrix where:
%   - The first subscript indicates the country (1 is China)
%   - The second subscript indicates the decade (1 is the fifties)
%   - The third subscript indicates the coefficient (a, b, c or d)
%   - The fourth subscript indicates the node interval (0-3, 3-6 or 6-9)
coefficients = zeros(5,7,4,3);

% As for the errors, we will store them in a matrix where the row indicates
% the decade and the column indicates the country.
error = zeros(5,7);

for country = 1:5
    for decade = 1:7
        [ay, bee, cee, dee] = ncspline(1940+decade*10, data(country,(decade-1)*10 + 1), data(country,(decade-1)*10 + 4), data(country,(decade-1)*10 + 7), data(country,(decade-1)*10 + 10));
        coefficients(country, decade, 1, :) = ay;
        coefficients(country, decade, 2, :) = bee;
        coefficients(country, decade, 3, :) = cee;
        coefficients(country, decade, 4, :) = dee;
    end
end

syms x

for country = 1:5
    clc;

    % Each country will be represented by a color. We chose the most
    % representative color of each flag (almost).
    switch country
        case 1
            color = 'r'; % Red for China
            disp('Plotting: China...      ');
        case 2
            color = 'g'; % Green for India
            disp('Plotting: India...      ');
        case 3
            color = 'k'; % Black for Libya
            disp('Plotting: Libya...      ');
        case 4
            color = 'c'; % Cyan for Russia
            disp('Plotting: Russia...      ');
        case 5
            color = 'b'; % Blue for the United States
            disp('Plotting: United States...      ');
    end
    
    % Setting up the graphs for each country
    subplot(3,2,country);
    sgtitle('Babies per woman');
    ylim([1, 9]);
    switch country
        case 1
            title('China');
        case 2
            title('India');
        case 3
            title('Libya');
        case 4
            title('Russia');
        case 5
            title('United States');
    end
    
    for decade = 1:7
        hold on
        leftnode = decade*10 + 1940;
        for node = 1:3
            % Storing the coefficients and (x - t)^k in vectors allows us
            % to express the polynomial in a more elegant and compact way.
            v = [coefficients(country,decade,1,node) coefficients(country,decade,2,node) coefficients(country,decade,3,node) coefficients(country,decade,4,node)];
            powers =[1; x-leftnode; (x-leftnode)^2; (x-leftnode)^3];
            fplot(v*powers, [leftnode, leftnode+3], color);
            
            % We can take advantage of this loop to find the error as well
            for t = leftnode + 1:leftnode + 2
                errorpowers = [1; t-leftnode; (t-leftnode)^2; (t-leftnode)^3];
                error(country,decade) = error(country,decade) + (abs(v*errorpowers - data(country,(t-1950))))^2;
            end
            
            % We also scatterplot the real values for this interval
            scatter(babiesperwoman(1,(decade-1)*10+(node-1)*3+1:1+(decade-1)*10+node*3),data(country,(decade-1)*10+(node-1)*3+1:1+(decade-1)*10+node*3), '.', color);
            
            % Prepare the left node for the next iteration
            leftnode = leftnode + 3;
            
            % Display a fancy progress percentage
            fprintf(repmat('\b',1,7));
            fprintf('\n%4.1f%%\n', ((decade-1)*3+node)/21*100)
        end
    end
end
error = sqrt(error); % Once we are done we can get the norm

clc;
disp('All countries plotted.');

% CONSTRUCTING THE TABLE
error = table(error(:,1), error(:,2), error(:,3), error(:,4), error(:,5), error(:,6), error(:,7), 'VariableNames', {'Fifties','Sixties','Seventies','Eighties','Nineties','Noughties','Teens'}, 'RowNames', {'China', 'India', 'Libya', 'Russia', 'United States'});

% OUTPUT
    % Question 1
fprintf('     TABLE OF MEASURED ERRORS\n')
disp(error);

fprintf('     ANALYSIS OF THE ERRORS\n');
fprintf('We can see that the data studied is a variable that can be easily interpolated. In almost every\ncountry the errors have been minimal, barely noticeable, except for China, whose graph has quite big\nerrors that can be explained due to major sociopolitical events that transpired in the country.\n\n');
fprintf('The first birthrate drop occurred in a period of vast hunger, known as the Great Chinese Famine, that\ntook place between 1959 and 1961 and caused the overall population and birthrate of China to\ndiminish. It is widely regarded as the deadliest famine and one of the greatest man-made disasters in\nhistory. In the need of repopulating the country, Chinese leader Mao Zedong created new politics that\nencouraged people to have children, causing the birthrate to grow abruptly in the 60''s. The second\ndrop can be attributed to the urbanization and change of mentality of the Chinese society. More women\nhad access to education, so they focused on their own future and postponed having offspring. In\naddition, contraceptive methods widely spread around this time as well. At around 1970 the population\nof China was still huge, and scientists foresaw another crisis if it kept growing at such a fast\nrate, and the government implemented the one child policy in 1980. Since then, the birth rate has\nbeen more stable, without any major error, even after China officially abandoned the policy in 2015.\n\n');
fprintf('As for the rest of the countries, even though one would expect the data to be more erratic during\ntimes like the baby boom in America, or the wars in Libya, the data stayed very predictable, and the\nspline functions had very small deviances.\n\n');

fprintf('     ARE DATA BECOMING MORE OR LESS DIFFICULT TO EXPLAIN WITH TIME? WHAT DOES THIS SUGGEST IN TERMS\nOF THESE VARIABLES?\n');
fprintf('Birthrate data has had two major inflection points: the baby boom after World War II and the\nawareness of overpopulation and spread of contraceptives which caused it to fall as sexual relations\nstopped being indivisible from reproduction (Hans Rosling). The noughties and teens in some other\nrich countries also have a slight increase in birthrate due to immigration. However, most countries\nfollow a similar pattern, even if developed countries have a lower birthrate than underdeveloped\nones. The country with the highest variation in data, Libya, was predicted almost perfectly by the\nspline function. We can conclude this variable is generally stable and appropriate for spline\ninterpolation.\n');
fprintf('\n "Government has no saying in the people''s bedrooms."\n              - Hans Rosling\n')

function [a, b, c, d] = ncspline (decade, y1, y2, y3, y4)
% This algorithm outputs the coefficients for an *actual* natural cubic
% spline with nodes separated by 3 units. Below is the formula to use them:
% S_j(x) = a(j) + b(j)*(x - t(j)) + t(j)*(x - t(j))^2 + d(j)(x - t(j))^3
% This algorithm is based off of another one explained in Numerical
% Analysis, a book by Richard L. Burden and J. Douglas Faires, and is
% equivalent to the one described in Chapter 2 of this course's notes.
% It was designed specifically for this exercise, not as a general way to
% find splines.

x = [decade, decade+3, decade+6, decade+9];
a = [y1, y2, y3, y4];

% Step 1
h = zeros(1,3);
for i=1:3
    h(i) = x(i+1) - x(i);
end

% Step 2
alpha = zeros(1,4);
for i=2:3
    alpha(i) = (a(i+1)-a(i))*3/h(i) - (a(i) - a(i-1))*3/h(i-1);
end

% Step 3
l = ones(1,4);
u = zeros(1,3);
z = zeros(1,4);

% Step 4
for i=2:3
    l(i) = 2*(x(i+1) - x(i-1)) - h(i-1)*u(i-1);
    u(i) = h(i)/l(i);
    z(i) = (alpha(i) - h(i-1)*z(i-1))/l(i);
end

% Step 5
z(4) = 0;
c(4) = 0;

% Step 6
for j=3:-1:1
    c(j) = z(j) - u(j)*c(j+1);
    b(j) = (a(j+1) - a(j))/h(j)-h(j)*(c(j+1)+2*c(j))/3;
    d(j) = (c(j+1)-c(j))/(3*h(j));
end
a(4) = [];
c(4) = [];
% We don't need these and it will be convenient to have a, b, c and d be the same length
end
