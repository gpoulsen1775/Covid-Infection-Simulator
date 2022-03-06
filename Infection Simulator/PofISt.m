classdef PofISt < handle
    
    % Probability of Infection by Stastistic Sampling:
    %
    % This Class approximates the Probability of Infection by sampling
    % from the RWA class a large number of times.
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
        
        %Vector For Calculating & Graphing Lambdas
        data;
        
    end
    
    
    methods (Access = public)
        
        function obj = PofISt(n,roomV,tpre,t,instances)
            
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
            
            else
                disp('Object Needs Input');
            end
            
        end
        
        %Returns the Probability of Infection
        function p = pOfI(obj)
            
            infCount = 0;
            s = size(obj.data(:,1));
            
            for i = 1: s(1,1)
                
                if(obj.data(i,1) >= 280) 
                    infCount = infCount + 1;
                end
                
            end
 
            p = infCount/s(1,1);
        end
        
        %Returns a Histogram of Lambda Values
        function a = graphLambda(obj)
            
            %Make a Histogram Out of Our Lambda Values
            a = histogram(obj.data);
        end

    end
end

