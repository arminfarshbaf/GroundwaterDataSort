%% Data sort and replacement of missing data for Groundwater
clear
clc
% [~,~,Data] = xlsread('Qazvin');
% [~,~,Data] = xlsread('Zanjan');
%% Comparing Strings and Cropping Station Data
for i = 1:numel(unique(Data(:,1)))-1 %minus one cause of header
    if i == 1
        Compare{i} = Data(strcmp(Data(:,1),Data(2,1))); %StringCompare
        Element_Order(i) = numel(Compare{i});
        Crop{i} = Data(2:Element_Order(i)+1,:);
    else
        Compare{i} = Data(strcmp(Data(:,1),Data(2+Element_Order(i-1),1)));
        Element_Order(i) = Element_Order(i-1)+numel(Compare{i});
        Crop{i} = Data(Element_Order(i-1)+2:Element_Order(i)+1,:);
    end
end
%% Counting each station's values
for i = 1:numel(Crop)
    Element_Count (i) = size(Crop{i},1);
end
%% Extracting Dates and Removing Stations with less than 10 yrs of Data
for i = 1:numel(Crop)
    SD(i) = Crop{i}(1,7);
    Starting_Dates(i) = datetime(SD(i),'InputFormat','MM/dd/yyyy');
    ED(i) = Crop{i}(size(Crop{i},1),7);
    Ending_Dates(i) = datetime(ED(i),'InputFormat','MM/dd/yyyy');
end

Duration = years(Ending_Dates - Starting_Dates);
Less_Than_Ten_Years = find(Duration<10);

Crop(Less_Than_Ten_Years) = [];
Element_Count(Less_Than_Ten_Years) = [];
Starting_Dates(Less_Than_Ten_Years) = [];
Ending_Dates(Less_Than_Ten_Years) = [];

%% Extracting Count of NaN and thresholding based on NaN count
for i = 1:numel(Crop)
    idn{i} = cellfun(@isnumeric,Crop{1,i}(:,12)); %logical among Heads
    Count_Numeric(i) = sum(idn{1,i});
end

Numeric_Percent = 100*(Count_Numeric./Element_Count);
Threshold = find(Numeric_Percent > 70);

Crop = Crop(Threshold);
Starting_Dates = Starting_Dates(Threshold);
Ending_Dates = Ending_Dates(Threshold);
%% Finding & Extrapolating NaN values
for i = 1:numel(Crop)
    IDN{i} = cellfun(@isnumeric,Crop{1,i}(:,end));
    IDX = find(IDN{i} == 0);
    No_Value{i} = IDX;
end

for i = 1:numel(Crop)
    % if first and second values are NaN then replace them with the 1st
    % corresponding value that isn't NaN
    if sum(No_Value{i} == 2) == 1 && sum(No_Value{i} == 1) == 1 
        A = 1:numel(Crop{i});
        A(A(No_Value{i})) = [];
        Crop{i}(No_Value{i}(1),end) = Crop{i}(A(1),end);
        Crop{i}(No_Value{i}(2),end) = Crop{i}(A(1),end);
        No_Value{i}(1) = [];
        No_Value{i}(1) = [];
    elseif sum(No_Value{i} == 1) == 1
        % if the 1st cell is NaN replace with 2nd
        Crop{i}(No_Value{i}(1),end) = Crop{i}(2,end);
        No_Value{i}(1) = [];
    elseif sum(No_Value{i} == 2) == 1
        % if the 2nd cell is NaN replace with 1st
        Crop{i}(No_Value{i}(1),end) = Crop{i}(1,end);
        No_Value{i}(1) = [];
    end
end

% Extrapolate NaN values using "fit" function
for i = 1:numel(Crop)
    for j = 1:numel(No_Value{i})
        a = (1:No_Value{i}(j)-1)';
        b = cell2mat(Crop{i}(1:No_Value{i}(j)-1,end));
        Fit = fit(a,b,'linearinterp');
        Crop{i}(No_Value{i}(j),end) = mat2cell(Fit(No_Value{i}(j)),1);
    end
end

%% Exporting final values
Export = [];
for i = 1:numel(Crop)
    Export1 = [Crop{i}];
    Export = [Export;Export1];
end
writecell(Export)
% filename = 'Qazvin_Mod.xlsx';
% xlswrite(filename,Crop)