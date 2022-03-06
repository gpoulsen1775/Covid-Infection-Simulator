classdef RWV < handle
    
    % RWV: Random Walk W/ Virions MORE PRIMATIVE MODEL/FILE
    %
    % This Object Simulates a Room Full of Virions with n infected
    % people and 1 succeptible individual. The Simulation accounts for room
    % size, how long the infected were in the room before the succeptible
    % individual's entering, and the amount of time the succeptible
    % individual spends in the room. 
    %
    % People: Each individual is placed in the room Uniformly and is
    % moved Uniformly. The Height of each person moves up and down just
    % slightly according to a Normal Distribution. 
    %
    % Random Variables for People:
    %
    % Height of People: N~(1.71,.0925)
    % Placement of People on (x,y): U~(0,(2^(1/2))*(roomV)^(1/3))
    % Fluctuation in Height (z): N~(0,.01)
    % Movement of People on (x,y): U~(-.5,.5)
    % 
    % Virions: The Virions are placeed according to a Normal Distribution
    % and moved according to a Unifrom Distribution.
    %
    % Random Variables for Virions: 
    %
    % Distance From Infected Person Origin: N~(0,.75)
    % Virions Bounce From Wall (to prevent stagnation): U~(.01,1)
    % Distance in Movement of Virions in (x,y,z): U~(-1,1)
    %
    % Units: Volume: m^3, Time: minutes, Distance: m
    %
    % Note: Room Dimesnions are predetermined to be Width = Length 
    % = root(2)*(roomV)^(1/3) and the Height = (.5)*(roomV)^(1/3)
    

    properties (Access = private)
        
        %Simulation Variables
        
        % The Head of The Suceptible Individual 
        head;
        
        % Variable For tracking each virion
        % (x,y,z,timeExpiredSinceCreation)
        virions;
        
        % Variable For tracking Infected
        % (x,y,z)
        n;
        
        % Counter Variable For the number of 
        % Virions the Suceptible person
        % has come into Contact With
        ve;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Computational Variables
        
        % Volume of the Room
        roomV;
        
        % Time n infected have been in room 
        tpre;
        
        % Time the suceptible person sepnds in the room
        t;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % Graphing Variable
        
        % x,y,z points of head at each time step
        headHistory;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % User Preferances
        
        % Boolean to determine if the user wants graphing on 
        graphing = false(1,1);
        
    end
    
    
   methods (Access = public)
        
        function obj = RWV(n,roomV,tpre,t)
       
            if nargin == 4

                %Num of Steps For Simulation 2 in segments of 30 seconds
                dt2 = ceil(t/.5);

                %Set Class Variables
                obj.headHistory = zeros(dt2 + 1,3);
                obj.head = [0,0,0];
                obj.roomV = roomV;
                obj.tpre = tpre;
                obj.ve = 0;
                obj.t = t;

                %Initialize Simulation Variables
                obj.n = zeros(n,3); 
                obj.virions = zeros(30*n*(tpre + t) + 1,4); 
            
            end
        end 
        
        %Runs the Simulation 
        function runSim(obj) 
            
            %Reset Class Properties
            obj.setDef();
            
            %Num of 30 second steps For Simulation 1
            dt1 = ceil(obj.tpre/.5);
            
            %Num of 30 second steps For Simulation 2
            dt2 = ceil(obj.t/.5);
            
            %Function for V(t)
            vt = obj.virionsAtT();
            
            %Prime Simulation 1
            obj.placeInfected();
            
            %We do a simulation to setup the room before 
            %the succeptible person enters.
            for i = 1 : dt1
                
                nvc = ceil(vt(-obj.tpre + (obj.tpre*i/dt1)) - vt(-obj.tpre + (obj.tpre*(i-1)/dt1)));
                obj.placeNewVirions(nvc);
                obj.moveVirions();
                
                %Remove Virions That have expired
                if i >= 140
                 
                    while(obj.virions(1,4) >= 70)
                        
                        obj.virions(1,:) = [];
                    end
                end
                 
                obj.moveInfected();
                
            end
            
            %Position Our Head
            obj.placeHead();
            obj.updateHeadHistory(1);
            
            %Figure Count
            fc = 1;
            
            %Graph Initial Figure if the user would like
            if(obj.graphing == true(1,1))   
            obj.graphVirions(fc);
            hold on;
            plot3(obj.headHistory(1,1),obj.headHistory(1,2),obj.headHistory(1,3),'.g', 'MarkerSize', 20);
            hold on;
            title("Room at 0 Minutes");
            end
            
            %Incrament
            fc = fc + 1;
            
            %Simulate the Random Walk For Suceptible Person
            for i = 1 : dt2
                
                %Find out New Amount Of Virions, Place them, and then move
                %them
                nvc = ceil(vt((obj.t*i/dt2)) - vt((obj.t*(i-1)/dt2)));
                obj.placeNewVirions(nvc);
                obj.moveVirions();
                
                %If we're Beyond Expiring Threshold Remove 
                if i + dt1 >= 140
                 
                    while(obj.virions(1,4) >= 70)
                        
                        obj.virions(1,:) = [];
                    end
                end
                
                %Move People & Update the count
                obj.moveInfected();
                obj.moveHead();
                obj.updateHeadHistory(i + 1);
                
                %Graph If Asked On A Time Scale of Every 5 Minutes
                if( (mod(i,10) == 0) && (obj.graphing == true(1,1)))
                    
                    obj.graphVirions(fc);
                    obj.graphHead(fc);
                    
                    fc = fc + 1;
                end
            end
            
            %If Graphing is on, give a graph of the head's movement alone
            if (obj.graphing == true(1,1))
                
            obj.graphHeadAlone(fc);  
            xlim([0,(2^(1/2))*(obj.roomV)^(1/3)]);
            ylim([0,(2^(1/2))*(obj.roomV)^(1/3)]);
            zlim([0,((obj.roomV)^(1/3))/2]);
            
            end
            
        end
        
        %Returns How Many Virions Have Been Encountered
        function v = virionEncounters(obj)
            
            v = obj.ve;
        end
        
        %Turns On Visual Aids
        function graphSim(obj)
            
            obj.graphing = true(1,1);
        end
        
        %Turns Off Visual Aids
        function noGraphs(obj)
            
            obj.graphing = false(1,1);
            
        end
        
    end
    
   
   methods (Access = private)
        
        %This Method Places our infected people
        function placeInfected(obj)
             
             %Distribution to pick hieght of Infected People
             height = makedist('Normal', 'mu', 1.71, 'sigma', .0925);
             
             %Uniform RV for determining posiiton in the room
             pos = makedist('Uniform','lower',0,'upper',(2^(1/2))*(obj.roomV)^(1/3));
             
             %Number of Infected & Placement
             s = size(obj.n);
             for i = 1: s(1,1)
             
                 %Place the Infected according to x,y,z
                 obj.n(i,1) = random(pos,1,1);
                 obj.n(i,2) = random(pos,1,1);
                 obj.n(i,3) = random(height,1,1);
                 
             end
        end
        
        %This Method Places new Virions Uniformly From Infected W/ Bounce
        %Back if the viral particles hit walls
        function placeNewVirions(obj,nvc) 
            
            %Make Distribution for distance of virion from origin
            d = makedist('Normal', 'mu', 0, 'sigma', .75);
            
            %Uniform RV to determine bounce from wall
            b = makedist('Uniform', 'lower', .01,'upper', 1);
             
            %Number of Virions rn
            s = obj.virions(:,1);
            vc = nnz(s);
            
            %Number of Infected
            ns = size(obj.n);
            n = ns(1,1);
            
            %How many we do for the last group
            leftover = mod(nvc,n);
            
            %Index
            i = vc + 1;
            
            %For Each Infected Person
            for j = 1: n
                    
                    %Either Distribute Equally or distribute a little less
                    %to the last infected person
                    if (j ~= n && leftover ~= 0) || (leftover == 0)

                        %Distribute equally to each infected
                        while i <= j*floor(nvc/n) + vc

                            obj.virions(i,1) = obj.n(j,1) + random(d,1,1);
                            obj.virions(i,2) = obj.n(j,2) + random(d,1,1);
                            obj.virions(i,3) = obj.n(j,3) + random(d,1,1);
                            
                             %If x comp is out of bounds fix
                             while obj.virions(i,1) > (2^(1/2))*(obj.roomV)^(1/3)

                                 obj.virions(i,1) = (2^(1/2))*(obj.roomV)^(1/3) - random(b,1,1);
                             end

                             %If y comp is out of bounds fix
                             while obj.virions(i,2) > (2^(1/2))*(obj.roomV)^(1/3)

                                 obj.virions(i,2) = (2^(1/2))*(obj.roomV)^(1/3) - random(b,1,1);
                             end

                             %If z comp is out of bounds fix
                             while obj.virions(i,3) > ((obj.roomV)^(1/3)/2)

                                 obj.virions(i,3) = ((obj.roomV)^(1/3)/2) - random(b,1,1);
                             end

                             %If x comp is less than 0 set to 0
                             while obj.virions(i,1) <= 0 

                                 obj.virions(i,1) = random(b,1,1);
                             end

                             %If y comp is less than 0 set to 0
                             while obj.virions(i,2) <= 0

                                 obj.virions(i,2) = random(b,1,1);
                             end

                             %If z comp is less than 0 set to 0
                             while obj.virions(i,3) <= 0

                                 obj.virions(i,3) = random(b,1,1);
                             end
                             
                             %Incrament Index
                             i = i + 1;

                        end

                    else

                        %If we're on the last person we do it for how many are
                        %leftover 
                        while i <= j*floor(nvc/n) + leftover + vc

                            obj.virions(i,1) = obj.n(j,1) + random(d,1,1);
                            obj.virions(i,2) = obj.n(j,2) + random(d,1,1);
                            obj.virions(i,3) = obj.n(j,3) + random(d,1,1);
                            
                             %If x comp is out of bounds fix
                             while(obj.virions(i,1) > (2^(1/2))*(obj.roomV)^(1/3))

                                 obj.virions(i,1) = (2^(1/2))*(obj.roomV)^(1/3) - random(b,1,1);
                             end

                             %If y comp is out of bounds fix
                             while(obj.virions(i,2) > (2^(1/2))*(obj.roomV)^(1/3))

                                 obj.virions(i,2) = (2^(1/2))*(obj.roomV)^(1/3) - random(b,1,1);
                             end

                             %If z comp is out of bounds fix
                             while(obj.virions(i,3) > ((obj.roomV)^(1/3)/2))

                                 obj.virions(i,3) = ((obj.roomV)^(1/3)/2) - random(b,1,1);
                             end

                             %If x comp is less than 0 set to 0
                             while(obj.virions(i,1) <= 0)

                                 obj.virions(i,1) = random(b,1,1);
                             end

                             %If y comp is less than 0 set to 0
                             while(obj.virions(i,2) <= 0)

                                 obj.virions(i,2) = random(b,1,1);
                             end

                             %If z comp is less than 0 set to 0
                             while(obj.virions(i,3) <= 0)

                                 obj.virions(i,3) = random(b,1,1);
                             end
                             
                             %Incrament Index
                             i = i + 1;

                        end
                    end  
            end
        end
        
        %Moves the Infected People
        function moveInfected(obj)
            
           %Make Distribution for distance you move in x,y and z
           d = makedist('Uniform', 'lower', -.5, 'upper', .5);
           height = makedist('Normal', 'mu', 0, 'sigma', .01);
           
           %Number of infected
           s = size(obj.n);
           n = s(1,1);
           
           %For each infected person
           for i = 1: n
           
           %Randomly move x,y, and z(slightly)
           obj.n(i,1) = obj.n(i,1) + random(d,1,1);
           obj.n(i,2) = obj.n(i,2) + random(d,1,1);
           obj.n(i,3) = obj.n(i,3) + random(height,1,1);
           
            %If any x component is out of bounds fix
            if(obj.n(i,1) > (2^(1/2))*(obj.roomV)^(1/3))
                     
               obj.n(i,1) = (2^(1/2))*(obj.roomV)^(1/3);
            end
                 
            %If any y component is out of bounds fix
            if(obj.n(1,2) > (2^(1/2))*(obj.roomV)^(1/3))
                     
               obj.n(1,2) = (2^(1/2))*(obj.roomV)^(1/3);
            end
                 
            %If any z component is out of bounds fix
            if(obj.n(1,3) > ((obj.roomV)^(1/3)/2))
                     
               obj.n(1,3) = ((obj.roomV)^(1/3)/2);
            end
            
             %If x comp is less than 0 set to 0
             if(obj.n(i,1) < 0)

                 obj.n(i,1) = 0;
             end

             %If y comp is less than 0 set to 0
             if(obj.n(i,2) < 0)

                 obj.n(i,2) = 0;
             end

             %If z come pis less than 0 set to 0
             if(obj.n(i,3) < 0)

                 obj.n(i,3) = 0;
             end
             
           end
           
        end
        
        %This Method Moves Existing Virions
        function moveVirions(obj)
            
            %Uniformly move up to a meter in any direction
            d = makedist('Uniform', 'lower', -1, 'upper', 1);
            
            %Random Bounce if hitting a wall
            b = makedist('Uniform', 'lower', .01, 'upper', 1);
            
            %Virion Count
            s = obj.virions(:,1);
            vc = nnz(s);
            
            %For each virion 
            for i = 1: vc
                
                obj.virions(i,1) = obj.virions(i,1) + random(d,1,1);
                obj.virions(i,2) = obj.virions(i,2) + random(d,1,1);
                obj.virions(i,3) = obj.virions(i,3) + random(d,1,1);
                obj.virions(i,4) = obj.virions(i,4) + .5;
                
                 %While x comp is out of bounds fix
                 while obj.virions(i,1) > (2^(1/2))*(obj.roomV)^(1/3)

                     obj.virions(i,1) = (2^(1/2))*(obj.roomV)^(1/3) - random(b,1,1);
                 end

                 %While y comp is out of bounds fix
                 while obj.virions(i,2) > (2^(1/2))*(obj.roomV)^(1/3)

                     obj.virions(i,2) = (2^(1/2))*(obj.roomV)^(1/3) - random(b,1,1);
                 end

                 %While z comp is out of bounds fix
                 while obj.virions(i,3) > ((obj.roomV)^(1/3)/2)

                     obj.virions(i,3) = ((obj.roomV)^(1/3)/2) - random(b,1,1);
                 end

                 %While x comp is less than 0 fix
                 while obj.virions(i,1) <= 0 

                     obj.virions(i,1) = random(b,1,1);
                 end

                 %While y comp is less than 0 fix
                 while obj.virions(i,2) <= 0

                     obj.virions(i,2) = random(b,1,1);
                 end

                 %While z comp is less than 0 fix
                 while obj.virions(i,3) <= 0

                     obj.virions(i,3) = random(b,1,1);
                 end
            end 
        end
        
        %This Method Places the Succeptible Head
        function placeHead(obj)
            
             %Distribution to pick hieght of Suceptible 
             height = makedist('Normal', 'mu', 1.71, 'sigma', .0925);
             
             %RV for position
             pos = makedist('Uniform', 'lower', 0, 'upper', (2^(1/2))*(obj.roomV)^(1/3));
             
             %Place Suceptible 
             obj.head(1,1) = random(pos,1,1);
             obj.head(1,2) = random(pos,1,1);
             obj.head(1,3) = random(height,1,1);
             
             %Radius of Average Human Head + Breathing Room 
             radius = .25;
             
             %Size of virions array
             s = obj.virions(:,1);
             
             %Tracking Removal & Such
             i = 1;
             removed = 0;
             
             %If the Head ever encounters a Virion add it to count and
             %remove
             while(i <= nnz(s)-removed)
                
                dist = ((obj.head(1,1)-obj.virions(i,1))^2 + (obj.head(1,2)-obj.virions(i,2))^2 + (obj.head(1,3)-obj.virions(i,3))^2)^.5;
                
                if(dist <= radius)
                    
                    obj.ve = obj.ve + 1;
                    obj.virions(i,:) = [];
                    removed = removed + 1;
                    i = i - 1;
                    
                end
                
                i = i + 1; 
                
             end
        end
        
        %This Method Moves our Head
        function moveHead(obj)
           
           %Make Distribution for distance you move
           d = makedist('Uniform', 'lower', -.5, 'upper', .5);
           height = makedist('Normal', 'mu', 0, 'sigma', .01);
           
           %Randomly move x,y, and z(slightly)
           obj.head(1,1) = obj.head(1,1) + random(d,1,1);
           obj.head(1,2) = obj.head(1,2) + random(d,1,1);
           obj.head(1,3) = obj.head(1,3) + random(height,1,1);
           
           
            %If x is out of bounds fix
            if(obj.head(1,1) > (2^(1/2))*(obj.roomV)^(1/3))
                     
               obj.head(1,1) = (2^(1/2))*(obj.roomV)^(1/3);
            end
                 
            %If y is out of bounds fix
            if(obj.head(1,2) > (2^(1/2))*(obj.roomV)^(1/3))
                     
               obj.head(1,2) = (2^(1/2))*(obj.roomV)^(1/3);
            end
                 
            %If z is out of bounds fix
            if(obj.head(1,3) > ((obj.roomV)^(1/3)/2))
                     
               obj.head(1,3) = ((obj.roomV)^(1/3)/2);
            end
            
            %If x is out of bounds fix
            if(obj.head(1,1) <= 0)
                     
               obj.head(1,1) = .01;
            end
                 
            %If y is out of bounds fix
            if(obj.head(1,2) <= 0)
                     
               obj.head(1,2) = .01;
            end
                 
            %If z is out of bounds fix
            if(obj.head(1,3) <= 0)
                     
               obj.head(1,3) = .01;
            end
           
            %Radius of Average Human Head + Some Breathing Room
            radius = .25;
            
            %Size of virions array
            s = obj.virions(:,1);
            
            %Index Tracking
            i = 1;
            removed = 0;
            
            %If the Head ever encounters a Virion add it to count and
            %remove
             while(i <= nnz(s) - removed)
                
                dist = ((obj.head(1,1)-obj.virions(i,1))^2 + (obj.head(1,2)-obj.virions(i,2))^2 + (obj.head(1,3)-obj.virions(i,3))^2)^.5;
                
                if(dist <= radius)
                    
                    obj.ve = obj.ve + 1;
                    obj.virions(i,:) = [];
                    i = i - 1;
                    removed = removed + 1;
                end
                
                i = i + 1;
            end
            
        end
        
        %This method makes a function for V(t)
        function vt = virionsAtT(obj)
            
            %Number of Infected
            s = size(obj.n(:,1));
            n = s(1,1);
            
            vt = @(t) (30*n)*(obj.tpre + t);
        end 
         
        %This method graphs virions 
        function graphVirions(obj,figureCount)
             
             s = obj.virions(:,1);
             vc = nnz(s);
             
             figure(figureCount);
             
             %Graph All of the Virions
             for i = 1: vc
                plot3(obj.virions(i,1),obj.virions(i,2),obj.virions(i,3),'or', 'MarkerSize', 4);
                hold on; 
             end
             
        end
        
        %Graphs lines from head history
        function graphHead(obj,step)
            
            %For Every Time Stamp yet
            s = nnz(obj.headHistory(:,1)); 
            
            %Where the Head is Currently At 
            plot3(obj.headHistory(s,1),obj.headHistory(s,2),obj.headHistory(s,3),'.g', 'MarkerSize', 20);
            
            %Draw Up the Head's History
            for i = 2: s

            %Points to Draw line between
            x1 = obj.headHistory(i,1);
            x2 = obj.headHistory(i-1,1);
            
            y1 = obj.headHistory(i,2);
            y2 = obj.headHistory(i-1,2);
            
            z1 = obj.headHistory(i,3);
            z2 = obj.headHistory(i-1,3);
            
            %Plot Line
            figure(step)
            plot3([x1,x2],[y1,y2],[z1,z2],'b');
            hold on;
            
            %Title Graph
            title("Room at " + num2str((step-1) * 5) + " minutes");
            
            end
            
        end
        
        %Displays the Path of the Head
        function graphHeadAlone(obj,fc)
            
            %For All of the History
            s = size(obj.headHistory(:,1)); 
            c = s(1,1);
            
            for i = 2: c-1
            
            %Points to Draw line between
            x1 = obj.headHistory(i,1);
            x2 = obj.headHistory(i-1,1);
            
            y1 = obj.headHistory(i,2);
            y2 = obj.headHistory(i-1,2);
            
            z1 = obj.headHistory(i,3);
            z2 = obj.headHistory(i-1,3);
            
            %Plot Line
            figure(fc)
            plot3([x1,x2],[y1,y2],[z1,z2],'b');
            hold on;
            
            title('Path of Head');
            
            end
        end
         
        %This method saves the head's movement progression
        function updateHeadHistory(obj,step)
            
            obj.headHistory(step,1) = obj.head(1,1);
            obj.headHistory(step,2) = obj.head(1,2);
            obj.headHistory(step,3) = obj.head(1,3);
            
        end
        
        %This method resets the class properties for another simulation
        function setDef(obj)
            
             dt2 = ceil(obj.t/.5);
             s = size(obj.n(:,1));
             n = s(1,1);
            
            
             obj.virions = zeros(30*n*(obj.tpre + obj.t) + 1,4); 
             obj.headHistory = zeros(dt2 + 1,3);
             obj.head = [0,0,0];
             obj.ve = 0;
             obj.n = zeros(n,3); 
             
        end
        
    end
    
end