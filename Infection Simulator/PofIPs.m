classdef PofIPs < handle
    
    % Probability of Infection by Poisson:
    %
    % This Class Calculates the Probability of Infection by recovering
    % the parameter lambda using the RWA simulation class. P(I) is
    % determined by an infectious dose (280) and by a Poisson C.D.F.
    %
    % Object Parameters: n = number of infected people, roomV = volume of
    % room, tpre = time the infected spend in the room before the
    % succeptible person enters, t = time the suceptible person spends with
    % the infected people, instances = number of times we sample from the
    % simulator.
    %
    % Units: Volume: m^3, Time: Minutes
    %
    % Note: The Histogram feature is really freaking cool!
    
    properties (Access = private)
     
        %Aerosol Collision Simulator
        rw;
        
        %Mean Virions Encountered
        lambda;
        
        %Vector For Calculating & Graphing Lambdas
        data;
        
    end
    
    
    methods 
        
        function obj = PofIPs(n,roomV,tpre,t,instances)
            
            if nargin ~= 0
                
            %Make Simulator
            obj.rw = RWA(n,roomV,tpre,t);
            obj.rw.noGraphs();
            
            %Different Numbers of Virion Encounters
            obj.data = zeros(instances,1);
            
            %Collect a Number of Virion Encounters
            for i = 1: instances
                obj.rw.runSim();
                obj.data(i,1) = obj.rw.virionEncounters();
            end
            
            obj.lambda = 0;
            
            %Sum All of the data Points
            for j = 1: instances
            
                obj.lambda = obj.lambda + obj.data(j,1);
            end
            
            %Divide the Sum to get an average
            obj.lambda = obj.lambda/instances;
            
            
            else
                disp('Object Needs Input');
            end
            
        end
        
        %Returns the Probability of Infection
        function p = pOfI(obj)
            
            p = poisscdf(280,obj.lambda,'upper');
 
        end
        
        %Returns a Histogram of Lambda Values
        function a = graphLambda(obj)
            
            %Make a Histogram Out of Our Lambda Values
            a = histogram(obj.data);
        end

    end
end

